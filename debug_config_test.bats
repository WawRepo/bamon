load 'test/container/test_helpers.sh'

@test 'debug config test' {
  setup
  install_bamon user
  echo 'DEBUG: Testing config reset command'
  run run_bamon user config reset --force
  echo 'DEBUG: Status: '$status
  echo 'DEBUG: Output: '$output
  [ "$status" -eq 0 ]
}
