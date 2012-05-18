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

$got = $obj->post('no-exist');
is($got, undef, 'no-exist');
like($obj->errstr(), '/404/', 'no-exist' );

$got = $obj->post('no-exist', { 'get' => { 'foo' => 'bar' } });
is($got, undef, 'no-exist with get');
like($obj->errstr(), '/404/', 'no-exist with get' );
