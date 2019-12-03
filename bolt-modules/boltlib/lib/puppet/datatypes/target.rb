# frozen_string_literal: true

Puppet::DataTypes.create_type('Target') do
  begin
    # Making target.new error cleanly inside apply blocks will probably also rely on this
    inventory = Puppet.lookup(:bolt_inventory)

    inventory_version = inventory.version if defined? inventory.version
    target_implementation_class = if inventory == 'apply'
                                    Bolt::ApplyTarget
                                  elsif inventory_version != 1
                                    inventory.target_implementation_class
                                  end
  rescue Puppet::Context::UndefinedBindingError
    inventory_version = 1
  end
  load_file('bolt/target')

  if inventory_version == 1
    interface <<-PUPPET
      attributes => {
        uri => String[1],
        options => { type => Hash[String[1], Data], value => {} }
      },
      functions => {
        name => Callable[[], String[1]],
        host => Callable[[], Optional[String]],
        password => Callable[[], Optional[String[1]]],
        port => Callable[[], Optional[Integer]],
        protocol => Callable[[], Optional[String[1]]],
        user => Callable[[], Optional[String[1]]],
      }
    PUPPET
    implementation_class Bolt::Target
  else
    interface <<-PUPPET
      attributes => {
        uri => { type => Optional[String[1]], kind => given_or_derived },
        name => { type => Optional[String[1]] , kind => given_or_derived },
        safe_name => { type =>  String[1], kind => given_or_derived },
        target_alias => { type => Optional[Variant[String[1], Array[String[1]]]], kind => given_or_derived },
        config => { type => Optional[Hash[String[1], Data]], kind => given_or_derived },
        vars => { type => Optional[Hash[String[1], Data]], kind => given_or_derived },
        facts => { type => Optional[Hash[String[1], Data]], kind => given_or_derived },
        features => { type => Optional[Array[String[1]]], kind => given_or_derived },
        plugin_hooks => { type => Optional[Hash[String[1], Data]], kind => given_or_derived }
      },
      functions => {
        host => Callable[[], Optional[String]],
        password => Callable[[], Optional[String[1]]],
        port => Callable[[], Optional[Integer]],
        protocol => Callable[[], Optional[String[1]]],
        user => Callable[[], Optional[String[1]]],
      }
    PUPPET

    implementation_class target_implementation_class
  end
end
