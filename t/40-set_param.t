use strict;

use Test::More tests => 4;

our $PACKAGE;

BEGIN {
	my $file = 't/config.pl';
	unless (my $return = do($file)) {
		BAIL_OUT("couldn't parse $file: $@") if($@);
		BAIL_OUT("couldn't do $file: $!") unless(defined($return));
		BAIL_OUT("couldn't run $file") unless($return);
	}

	use_ok($PACKAGE);
}

my $got;

my $obj = $PACKAGE->new();

$got = $obj->set_param('base_uri', 'foobar');
is($got, 'foobar', 'base_uri');

$got = $obj->set_param('lwp_opts', 'agent', 'foobar');
is($got, 'foobar', 'lwp_opts => agent');

$got = $obj->get_param('foobar', 'foobar');
is($got, undef, 'invalid param');
