use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name		=> 'APIProducer::Consumer',
	license			=> 'perl',
	dist_author		=> 'Kimo Rosenbaum <kimor79@yahoo.com>',
	dist_version_from	=> 'lib/APIProducer/Consumer.pm',
	build_requires => {
		'Test::Deep'	=> 0,
		'Test::More'	=> 0,
		'Test::Pod'	=> 0,
		'Test::Pod::Coverage'	=> 0,
		'Test::Spelling'	=> 0,
		'Test::Strict'	=> 0,
	},
	requires => {
		'JSON::DWIW' => 0,
		'LWP::UserAgent' => 0,
		'Moose' => 0,
		'URI::Escape' => 0,
		'namespace::autoclean' => 0,
	},
	create_makefile_pl	=> 'traditional',
);

$builder->create_build_script();
