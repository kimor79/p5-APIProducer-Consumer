use strict;

use Test::More tests => 7;

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

$got = $obj->make_request('no-exist');
is($got, undef, 'no-exist');
is($obj->get_status(), '404', 'no-exist' );
like($obj->get_message(), '/Found/', 'no-exist' );

$got = $obj->make_request('no-exist', { 'get' => { 'foo' => 'bar' } });
is($got, undef, 'no-exist with get');
is($obj->get_status(), '404', 'no-exist with get' );
like($obj->get_message(), '/Found/', 'no-exist with get' );
