load 'test/container/test_helpers.sh'

@test 'debug test' {
  setup
  install_bamon user
  echo 'DEBUG: After install_bamon'
  ls -la $HOME/.local/bin/bamon
  echo 'DEBUG: Testing run_bamon directly'
  run_bamon user --help | head -3
  echo 'DEBUG: Testing with run function'
  run run_bamon user --help
  echo 'DEBUG: Status: '$status
  echo 'DEBUG: Output: '$output
  [ "$status" -eq 0 ]
}
