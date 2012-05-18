use strict;

use Test::More tests => 5;

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

$got = $obj->get_param('base_uri');
is($got, 'http://localhost/api/', 'base_uri');

$got = $obj->get_param('lwp_opts', 'agent');
like($got, '/APIProducer::Consumer\/[\d.]+/', 'agent');

$got = $obj->get_param('foobar');
is($got, undef, 'invalid param');

$got = $obj->get_param('');
is($got, undef, 'empty param');
