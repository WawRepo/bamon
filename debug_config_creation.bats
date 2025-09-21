load 'test/container/test_helpers.sh'

@test 'debug config creation' {
  setup
  install_bamon user
  rm -f "$BAMON_CONFIG_DIR/config.yaml"
  echo 'DEBUG: Before command, BAMON_CONFIG_DIR='$BAMON_CONFIG_DIR
  echo 'DEBUG: Directory exists:' $(ls -la "$BAMON_CONFIG_DIR" 2>/dev/null || echo 'NO')
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon user config reset --force
  echo 'DEBUG: Status:' $status
  echo 'DEBUG: Output:' $output
  echo 'DEBUG: After command, config file exists:' $(ls -la "$BAMON_CONFIG_DIR/config.yaml" 2>/dev/null || echo 'NO')
  echo 'DEBUG: Directory contents:' $(ls -la "$BAMON_CONFIG_DIR" 2>/dev/null || echo 'NO')
}
