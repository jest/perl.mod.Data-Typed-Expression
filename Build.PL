use warnings;
use strict;

use Module::Build;

my $build = Module::Build->new(
	module_name => 'Data::Typed::Expression',
	license => 'artistic_2',
	dist_author => 'Przemyslaw Wesolek <jest@go.art.pl>',
	requires => {
		'Carp' => 0,
		'Text::Balanced' => 0,
	},
	build_requires => {
		'Test::More' => 0,
		'Test::Exception' => 0.21,
	},
	add_to_cleanup => [ 'Data-Typed-Expression-*' ],
);
$build->create_build_script;
