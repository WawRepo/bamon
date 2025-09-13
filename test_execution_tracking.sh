#!/usr/bin/env bash

# Test script execution tracking
source src/lib/performance.sh

echo "Testing script execution tracking..."

# Reset any existing data
unset SCRIPT_EXECUTION_TIMES
unset SCRIPT_FAILURE_COUNTS
declare -A SCRIPT_EXECUTION_TIMES
declare -A SCRIPT_FAILURE_COUNTS

echo "1. Testing track_script_execution function directly..."

# Test successful execution
track_script_execution "test_script" "5" "true"
echo "   Tracked successful execution: 5 seconds"

# Test failed execution
track_script_execution "test_script2" "3" "false"
track_script_execution "test_script2" "2" "false"
echo "   Tracked failed executions: 3s and 2s"

# Test retrieval
echo "2. Testing retrieval functions..."
echo "   test_script execution time: $(get_script_avg_execution_time "test_script")"
echo "   test_script failure count: $(get_script_failure_count "test_script")"
echo "   test_script2 execution time: $(get_script_avg_execution_time "test_script2")"
echo "   test_script2 failure count: $(get_script_failure_count "test_script2")"

# Test performance report
echo "3. Testing performance report..."
generate_performance_report
