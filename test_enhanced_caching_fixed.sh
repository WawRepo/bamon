#!/usr/bin/env bash

# Test enhanced caching system functionality (fixed version)
source src/lib/performance.sh

echo "Testing Enhanced Caching System (Fixed)..."
echo "=========================================="

# Reset cache stats for clean test
reset_cache_stats

echo "1. Testing basic cache operations..."
set_cached_value "test1" "value1"
set_cached_value "test2" "value2"
set_cached_value "test3" "value3"

echo "   Stored 3 values"

# Test cache hits (without command substitution to preserve variable changes)
echo "2. Testing cache hits..."
if get_cached_value "test1" >/dev/null; then
  echo "   test1: HIT"
else
  echo "   test1: MISS"
fi

if get_cached_value "test2" >/dev/null; then
  echo "   test2: HIT"
else
  echo "   test2: MISS"
fi

if get_cached_value "test3" >/dev/null; then
  echo "   test3: HIT"
else
  echo "   test3: MISS"
fi

# Test cache miss
echo "3. Testing cache miss..."
if get_cached_value "nonexistent" >/dev/null; then
  echo "   nonexistent: HIT"
else
  echo "   nonexistent: MISS"
fi

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

if get_cached_value "ttl_test" >/dev/null; then
  echo "   Retrieved immediately: HIT"
else
  echo "   Retrieved immediately: MISS"
fi

echo "   Waiting 2 seconds for TTL expiration..."
sleep 2

if get_cached_value "ttl_test" >/dev/null; then
  echo "   Retrieved after TTL: HIT"
else
  echo "   Retrieved after TTL: MISS"
fi

# Final statistics
echo "8. Final cache statistics..."
get_cache_stats

echo ""
echo "Enhanced caching system test completed!"
