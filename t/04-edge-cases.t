use 5.006;
use strict;
use warnings;
use Test::More;
use Cache::File::Simple;

# cache() with no arguments — key becomes "", should return undef
is(cache(), undef, 'cache() with no arguments returns undef');

# cache() with undef key — set works (hashes to ""), but get requires truthy key
# The get path has: elsif ($key && -r $file), so undef/empty keys can't retrieve
cache(undef, "val1");
is(cache(), undef, 'cache() get with undef key returns undef (get requires truthy key)');

# cache() with empty string key — same limitation
cache("", "val2");
is(cache(""), undef, 'cache() get with empty string key returns undef');

# Overwrite existing key with different data type
cache('mkey', "scalar value");
is(cache('mkey'), "scalar value", 'scalar value stored');

cache('mkey', [1, 2, 3]);
my $ref = cache('mkey');
is_deeply($ref, [1, 2, 3], 'overwrite scalar with arrayref');

cache('mkey', { a => 1 });
my $href = cache('mkey');
is_deeply($href, { a => 1 }, 'overwrite arrayref with hashref');

# Set without explicit expiry — should use $DEFAULT_EXPIRE (3600s)
cache('def', "lifetime");
my $stored = cache('def');
is($stored, "lifetime", 'set without expiry stores value');

# Verify the entry is actually live (not expired)
is(Cache::File::Simple::has_cache('def'), 1, 'entry with default expiry is live');

# Clean up entries we created so they don't affect other test files
Cache::File::Simple::delete_cache('mkey');
Cache::File::Simple::delete_cache('def');
Cache::File::Simple::delete_cache('');
Cache::File::Simple::delete_cache(undef);

done_testing();
