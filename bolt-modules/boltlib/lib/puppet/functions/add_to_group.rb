# frozen_string_literal: true

require 'bolt/error'

# Adds a target to specified inventory group.
Puppet::Functions.create_function(:add_to_group) do
  # @param targets A pattern or array of patterns identifying a set of targets.
  # @param group The name of the group to add targets to.
  # @example Add new Target to group.
  #   Target.new('foo@example.com', 'password' => 'secret').add_to_group('group1')
  # @example Add new target to group by name.
  #   add_to_group('bolt:bolt@web.com', 'group1')
  # @example Add an array of targets to group by name.
  #   add_to_group(['host1', 'group1', 'winrm://host2:54321'], 'group1')
  # @example Add a comma separated list list of targets to group by name.
  #   add_to_group('foo,bar,baz', 'group1')
  dispatch :add_to_group do
    param 'Boltlib::TargetSpec', :targets
    param 'String[1]', :group
  end

  def add_to_group(targets, group)
    inventory = Puppet.lookup(:bolt_inventory) { nil }

    unless inventory && Puppet.features.bolt?
      raise Puppet::ParseErrorWithIssue.from_issue_and_stack(
        Puppet::Pops::Issues::TASK_MISSING_BOLT, action: _('process targets through inventory')
      )
    end

    executor = Puppet.lookup(:bolt_executor) { nil }
    executor&.report_function_call('add_to_group')

    inventory.add_to_group(inventory.get_targets(targets), group)
  end
end
