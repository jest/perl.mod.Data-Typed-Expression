use warnings;
use strict;

use Module::Build;

my $build = Module::Build->new(
	module_name => 'Data::Typed::Expression',
	license => 'artistic_2',
	dist_author => 'Przemyslaw Wesolek <jest@go.art.pl>',
	requires => {
		'Carp' => 0,
		'Parse::RecDescent' => 0,
	},
	build_requires => {
		'Test::More' => 0.81_01,
		'Test::Exception' => 0.21,
	},
	add_to_cleanup => [ 'Data-Typed-Expression-*' ],
	meta_merge => {
		resources => {
			repository => 'http://github.com/jest/perl.mod.Data-Typed-Expression'
		}
	},
);
$build->create_build_script;
