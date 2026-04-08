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

done_testing();
