# frozen_string_literal: true

require 'bolt/apply_target'
require 'bolt/config'
require 'bolt/error'
require 'bolt/inventory'
require 'bolt/pal'
require 'bolt/puppetdb'
require 'bolt/util'

Bolt::PAL.load_puppet

require 'bolt/catalog/logging'

module Bolt
  class Catalog
    def initialize(log_level = 'debug')
      @log_level = log_level
    end

    def with_puppet_settings(hiera_config = {})
      Dir.mktmpdir('bolt') do |dir|
        cli = []
        Puppet::Settings::REQUIRED_APP_SETTINGS.each do |setting|
          cli << "--#{setting}" << dir
        end
        Puppet.settings.send(:clear_everything_for_tests)
        # Override module locations, Bolt includes vendored modules in its internal modulepath.
        Puppet.settings.override_default(:basemodulepath, '')
        Puppet.settings.override_default(:vendormoduledir, '')

        Puppet.initialize_settings(cli)
        Puppet.settings[:hiera_config] = hiera_config

        # Use a special logdest that serializes all log messages and their level to stderr.
        Puppet::Util::Log.newdestination(:stderr)
        Puppet.settings[:log_level] = @log_level
        yield
      end
    end

    def generate_ast(code, filename = nil)
      with_puppet_settings do
        Puppet::Pal.in_tmp_environment("bolt_parse") do |pal|
          pal.with_catalog_compiler do |compiler|
            ast = compiler.parse_string(code, filename)
            Puppet::Pops::Serialization::ToDataConverter.convert(ast,
                                                                 rich_data: true,
                                                                 symbol_to_string: true)
          end
        end
      end
    end

    def setup_inventory(inventory)
      config = Bolt::Config.default
      config.overwrite_transport_data(inventory['config']['transport'],
                                      Bolt::Util.symbolize_top_level_keys(inventory['config']['transports']))

      Bolt::Inventory.new(inventory['data'],
                          config,
                          Bolt::Util.symbolize_top_level_keys(inventory['target_hash']))
    end

    def compile_catalog(request)
      pal_main = request['code_ast'] || request['code_string']
      target = request['target']
      pdb_client = Bolt::PuppetDB::Client.new(Bolt::PuppetDB::Config.new(request['pdb_config']))
      options = request['puppet_config'] || {}

      with_puppet_settings(request['hiera_config']) do
        Puppet[:rich_data] = true
        Puppet[:node_name_value] = target['name']
        Puppet::Pal.in_tmp_environment('bolt_catalog',
                                       modulepath: request["modulepath"] || [],
                                       facts: target["facts"] || {},
                                       variables: target["variables"] || {}) do |pal|
          inv = request['future'] ? 'apply' : setup_inventory(request['inventory'])
          Puppet.override(bolt_pdb_client: pdb_client,
                          bolt_inventory: inv) do
            Puppet.lookup(:pal_current_node).trusted_data = target['trusted']
            pal.with_catalog_compiler do |compiler|
              if request['future']
                # This needs to happen inside the catalog compiler so loaders are initialized for loading
                vars = Puppet::Pops::Serialization::FromDataConverter.convert(request['plan_vars'])
                # Set computed target data, such as user and host
                request['target_opts'].each do |var_name, target_data|
                  if vars[var_name].is_a?(Bolt::ApplyTarget)
                    target_data.each do |opt, value|
                      vars[var_name].send("#{opt}=", value)
                    end
                  elsif vars[var_name].is_a?(Bolt::Result)
                    target_data.each do |opt, value|
                      vars[var_name].target.send("#{opt}=", value)
                    end
                  elsif vars[var_name].is_a?(Bolt::ResultSet)
                    target_data.each do |target_name, target_opts|
                      rs_target = vars[var_name].find(target_name).target
                      target_opts.each do |rs_opt, rs_value|
                        rs_target.send("#{rs_opt}=", rs_value)
                      end
                    end
                  end
                end
                pal.send(:add_variables, compiler.send(:topscope), vars.merge(target['vars']))
              end

              # Configure language strictness in the CatalogCompiler. We want Bolt to be able
              # to compile most Puppet 4+ manifests, so we default to allowing deprecated functions.
              Puppet[:strict] = options['strict'] || :warning
              Puppet[:strict_variables] = options['strict_variables'] || false
              ast = Puppet::Pops::Serialization::FromDataConverter.convert(pal_main)
              begin
                compiler.evaluate(ast)
              rescue Puppet::PreformattedError => e
                if e.message =~ /Initializer for class Bolt::ApplyTarget does not match the attributes of Target/
                  # TODO: what's the right error type here?
                  raise Bolt::Error.new("Target objects cannot be instantiated inside apply blocks", 'bolt/apply-error')
                else
                  raise e
                end
              end
              compiler.compile_additions
              compiler.with_json_encoding(&:encode)
            end
          end
        end
      end
    end
  end
end
