use strict;

use Test::More tests => 3;

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
my $obj;

$obj = $PACKAGE->new();
$got = $obj->errstr();
is($got, '', 'errstr()');

$obj = $PACKAGE->new('lwp_opts' => { 'no-exist' => 0 });
$got = $APIProducer::Consumer::errstr;
like($got, '/Unrecognized/', 'errstr');
