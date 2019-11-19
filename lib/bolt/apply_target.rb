# frozen_string_literal: true

module Bolt
  class ApplyTarget
    ATTRIBUTES ||= %i[uri name target_alias config vars facts features
                      plugin_hooks safe_name].freeze
    COMPUTED ||= %i[host password port protocol user].freeze

    attr_reader *ATTRIBUTES
    attr_accessor *COMPUTED

    def self._pcore_init_from_hash(init_hash); end

    def _pcore_init_from_hash(init_hash)
      initialize(init_hash)
    end

    def initialize(target_hash)
      keys = ATTRIBUTES + COMPUTED
      keys.each do |attr|
        instance_variable_set("@#{attr}", target_hash[attr.to_s])
      end
    end
  end
end
