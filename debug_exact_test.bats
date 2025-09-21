load 'test/container/test_helpers.sh'

@test 'debug exact test' {
  setup
  install_bamon user
  rm -f "$BAMON_CONFIG_DIR/config.yaml"
  echo 'DEBUG: About to run exact command'
  run BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run_bamon user config reset --force
  echo 'DEBUG: Status: '$status
  echo 'DEBUG: Output: '$output
  [ "$status" -eq 0 ]
}
