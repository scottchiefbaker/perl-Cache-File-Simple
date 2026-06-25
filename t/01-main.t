use 5.006;
use strict;
use warnings;
use Test::More;
use Cache::File::Simple;

my $key = "foo";
my $val = "bar";

# Init the cache
cache($key, undef); # Clear cache

is(cache($key), undef,                'Fetch empty value');
is(cache($key , $val, time() + 1), 1, 'Set for 1 second');
is(cache($key), "bar",                'Fetch value we just set');

diag("Sleeping a couple seconds to let cache expire\n");
sleep(2);

# Entry should be expired now
is(cache($key), undef, 'Check cache expiration');

# Expired time should return undef
cache($key, 'donk', time() - 3600);
is(cache($key), undef, 'Expiration in past');

# Use this entry for the next couple of tests
cache('foo', 1234);

is(Cache::File::Simple::has_cache('foo')  , 1, 'has_cache() = true');
is(Cache::File::Simple::has_cache('bogus'), 0, 'has_cache() = false');

is(Cache::File::Simple::delete_cache('foo')  , 1, 'delete_cache() = true');
is(Cache::File::Simple::delete_cache('bogus'), 0, 'delete_cache() = false');

# Create some expired entries so we have something to clean
cache('foo', 1234, time() - 3600);
cache('bar', 1234, time() - 3600);
cache('bar', 1234, time() - 3600);

cmp_ok(Cache::File::Simple::cache_clean(), ">", 0, "cache_clean() works");

# has_cache() on an expired entry — should return 0 and clean up the file
cache('exp', 'gone soon', time() - 1);
is(Cache::File::Simple::has_cache('exp'), 0, 'has_cache() returns 0 for expired entry');

# Clean slate for cache_clean() tests
Cache::File::Simple::cache_clean();

# cache_clean() with no expired entries — should return 0
cache('fresh', 'alive', time() + 3600);
is(Cache::File::Simple::cache_clean(), 0, 'cache_clean() returns 0 when nothing expired');

# cache_clean() exact count: create 3 expired entries, verify count
# Remove the fresh entry first so only expired entries remain
Cache::File::Simple::delete_cache('fresh');
cache('c1', 'v1', time() - 100);
cache('c2', 'v2', time() - 100);
cache('c3', 'v3', time() - 100);
my $cleaned = Cache::File::Simple::cache_clean();
cmp_ok($cleaned, '>=', 3, 'cache_clean() removes at least 3 items (files + dirs)');

# Verify the specific expired entries we created are gone
is(Cache::File::Simple::has_cache('c1'), 0, 'cache_clean() removed c1');
is(Cache::File::Simple::has_cache('c2'), 0, 'cache_clean() removed c2');
is(Cache::File::Simple::has_cache('c3'), 0, 'cache_clean() removed c3');

# delete_cache() on an already-expired entry
cache('del_exp', 'val', time() - 1);
is(Cache::File::Simple::delete_cache('del_exp'), 1, 'delete_cache() returns 1 on expired entry file');

done_testing();
