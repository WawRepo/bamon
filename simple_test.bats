load 'test/container/test_helpers.sh'

@test 'simple test' {
  setup
  install_bamon user
  run run_bamon user --help
  [ "$status" -eq 0 ]
}
