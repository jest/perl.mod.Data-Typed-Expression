use Test::More tests => 9;
use Data::Typed::Expression;

my %tests = (
	abc => { op => 'V', l => 'abc' },
	1 => { op => 'I', l => '1' },
	12.3 => { op => 'D', l => '12.3' },
);

$tests{'a[b]'} = {
	op => '[]',
	l => {
		op => 'V',
		l => 'a'
	},
	r => [{
		op => 'V',
		l => 'b'
	}]
};

$tests{'a[b][c]'} = {
	op => '[]',
	l => { op => 'V', l => 'a' },
	r => [
		{ op => 'V', l => 'b' },
		{ op => 'V', l => 'c' }
	]
};

$tests{'a[b][c.d[123]]'} = {
	op => '[]',
	l => {
		op => 'V',
		l => 'a'
	},
	r => [{
		op => 'V',
		l => 'b'
	}, {
		op => '.',
		l => { op => 'V', l => 'c' },
		r => {
			op => '[]',
			l => { op => 'V', l => 'd' },
			r => [ { op => 'I', l => '123' } ]
		}
	}
	]
};

$tests{'a[b].c'} = {
	op => '.',
	l => $tests{'a[b]'},
	r => { op => 'V', l => 'c' }
};
$tests{'((a[(b)].c))'} = $tests{'a[b].c'};

for (keys %tests) {
	my $resu = Data::Typed::Expression::make_ast($_);
	use Data::Dumper;
#	print Dumper($resu);
	is_deeply($resu, $tests{$_}, "e := $_");
}

pass;

# jedit :mode=perl:
