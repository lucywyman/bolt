plan puppet_types::applyresult (
  TargetSpec $targets
) {
  $first = get_target($targets)
  $first.apply_prep
  run_command('rm -rf /home/bolt/tmp', $first)

  $result = apply($first) {
    file { '/home/bolt/tmp':
      ensure  => file,
    }
  }.first

  return apply($first) {
    notify { "ApplyResult resource: ${$result.report['resource_statuses']}": }
  }
}
