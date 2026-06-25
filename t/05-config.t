use 5.006;
use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use Cache::File::Simple;

# --- Test $CACHE_ROOT override ---
my $orig_root = $Cache::File::Simple::CACHE_ROOT;
my $tmpdir = tempdir(CLEANUP => 1);
$Cache::File::Simple::CACHE_ROOT = "$tmpdir/";

cache('cfgkey', 'cfgval');
is(cache('cfgkey'), 'cfgval', 'cache works with overridden CACHE_ROOT');

# Verify files actually went into the new dir
my @files = glob("$tmpdir/perl-cache/*/*.json");
cmp_ok(scalar(@files), '>', 0, 'cache files created under overridden CACHE_ROOT');

# Restore
$Cache::File::Simple::CACHE_ROOT = $orig_root;

# --- Test $DEFAULT_EXPIRE override ---
my $orig_expire = $Cache::File::Simple::DEFAULT_EXPIRE;
$Cache::File::Simple::DEFAULT_EXPIRE = 2;

cache('short', 'ephemeral');
is(cache('short'), 'ephemeral', 'entry stored with short default expiry');

diag("Sleeping 3 seconds to let short-expiry entry expire\n");
sleep(3);

is(cache('short'), undef, 'entry expired under overridden DEFAULT_EXPIRE');

# Restore
$Cache::File::Simple::DEFAULT_EXPIRE = $orig_expire;

done_testing();
