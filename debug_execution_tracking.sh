#!/usr/bin/env bash

# Debug execution tracking
source src/lib/performance.sh

echo "Testing execution tracking with debug output..."

# Reset any existing data
unset SCRIPT_EXECUTION_TIMES
unset SCRIPT_FAILURE_COUNTS
declare -A SCRIPT_EXECUTION_TIMES
declare -A SCRIPT_FAILURE_COUNTS

echo "1. Testing track_script_execution function..."

# Test with debug output
track_script_execution "test_script" "5" "true"
echo "   Tracked: test_script (5s, success)"

# Check if data was stored
echo "2. Checking stored data..."
echo "   SCRIPT_EXECUTION_TIMES[test_script]: ${SCRIPT_EXECUTION_TIMES[test_script]}"
echo "   SCRIPT_FAILURE_COUNTS[test_script]: ${SCRIPT_FAILURE_COUNTS[test_script]}"

# Test retrieval functions
echo "3. Testing retrieval functions..."
echo "   get_script_avg_execution_time: $(get_script_avg_execution_time "test_script")"
echo "   get_script_failure_count: $(get_script_failure_count "test_script")"

# Test with failure
track_script_execution "test_script2" "3" "false"
echo "   Tracked: test_script2 (3s, failure)"

echo "4. Checking failure data..."
echo "   SCRIPT_EXECUTION_TIMES[test_script2]: ${SCRIPT_EXECUTION_TIMES[test_script2]}"
echo "   SCRIPT_FAILURE_COUNTS[test_script2]: ${SCRIPT_FAILURE_COUNTS[test_script2]}"

echo "5. Testing performance report..."
generate_performance_report
