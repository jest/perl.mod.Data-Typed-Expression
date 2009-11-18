use Test::More 'no_plan';
use Test::Exception;

use Data::Typed::Expression;
use Data::Typed::Expression::Env;

# TODO: comment on deployment
use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my $types = {
	vertex => {
		id => 'int',
		lon => 'double',
		lat => 'double'
	},
	arc => {
		from => 'vertex',
		to => 'vertex',
		cost => 'double',
	},
	graph => {
		v => 'vertex[]',
		a => 'arc[]'
	},
	
	'int' => undef,
	'double' => undef,
	'bool' => undef,
};

my $vars = {
	graph => 'graph',
	v => 'vertex',
	someid => 'int',
};


my $env = new_ok( Data::Typed::Expression::Env, [ $types, $vars ] );
my $t = sub {
	my $expr = new_ok( Data::Typed::Expression, [ shift ] );
	lives_ok { $env->validate($expr) };
};

$t->($_) for qw( graph graph.v graph.v[someid] graph.v[0] );


my $expr = new_ok( Data::Typed::Expression, [ 'ala.ma.kota' ] );
dies_ok { $env->validate($expr) }


