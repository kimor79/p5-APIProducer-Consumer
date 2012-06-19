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

my $obj = $PACKAGE->new();

is($obj->_get('foo'), undef, '_get("foo")');
is($obj->_get('status'), 500, '_get("status")');
