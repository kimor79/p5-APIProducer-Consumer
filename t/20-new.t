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

new_ok($PACKAGE);
new_ok($PACKAGE => [ 'lwp_opts' => { 'agent' => '12345' } ]);
new_ok($PACKAGE => [ 'base_uri' => 'http://foobar/' ]);
