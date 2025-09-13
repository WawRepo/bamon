#!/usr/bin/env bash

# Test associative arrays functionality
source src/lib/performance.sh

echo "Testing associative arrays..."

# Test caching
echo "Testing cache..."
set_cached_value "test_key" "test_value"
cached_result=$(get_cached_value "test_key")
echo "Cached value: $cached_result"

# Test script execution tracking
echo "Testing script execution tracking..."
track_script_execution "test_script" "5" "true"
track_script_execution "test_script2" "3" "false"
track_script_execution "test_script2" "2" "false"

# Test retrieval
echo "Script 1 execution time: $(get_script_avg_execution_time "test_script")"
echo "Script 1 failure count: $(get_script_failure_count "test_script")"
echo "Script 2 execution time: $(get_script_avg_execution_time "test_script2")"
echo "Script 2 failure count: $(get_script_failure_count "test_script2")"

# Test performance report
echo "Generating performance report..."
generate_performance_report
