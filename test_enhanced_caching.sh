#!/usr/bin/env bash

# Test enhanced caching system functionality
source src/lib/performance.sh

echo "Testing Enhanced Caching System..."
echo "=================================="

# Reset cache stats for clean test
reset_cache_stats

echo "1. Testing basic cache operations..."
set_cached_value "test1" "value1"
set_cached_value "test2" "value2"
set_cached_value "test3" "value3"

echo "   Stored 3 values"

# Test cache hits
echo "2. Testing cache hits..."
result1=$(get_cached_value "test1")
result2=$(get_cached_value "test2")
result3=$(get_cached_value "test3")

echo "   Retrieved: test1='$result1', test2='$result2', test3='$result3'"

# Test cache miss
echo "3. Testing cache miss..."
get_cached_value "nonexistent" 2>/dev/null
echo "   Attempted to retrieve nonexistent key (should be miss)"

# Test cache statistics
echo "4. Testing cache statistics..."
get_cache_stats

# Test cache hit rate calculation
echo "5. Testing cache hit rate..."
hit_rate=$(get_cache_hit_rate)
echo "   Hit rate: $hit_rate%"

# Test cache size limits (simulate by setting a small limit)
echo "6. Testing cache size limits..."
MAX_CACHE_SIZE=2
set_cached_value "test4" "value4"
set_cached_value "test5" "value5"
echo "   Added more values with size limit of 2"

get_cache_stats

# Test TTL expiration (simulate by setting very short TTL)
echo "7. Testing TTL expiration..."
CACHE_TTL=1
set_cached_value "ttl_test" "ttl_value"
echo "   Stored value with 1s TTL"
echo "   Retrieved immediately: $(get_cached_value "ttl_test")"

echo "   Waiting 2 seconds for TTL expiration..."
sleep 2

echo "   Retrieved after TTL: $(get_cached_value "ttl_test" 2>/dev/null || echo "MISS")"

# Final statistics
echo "8. Final cache statistics..."
get_cache_stats

echo ""
echo "Enhanced caching system test completed!"
