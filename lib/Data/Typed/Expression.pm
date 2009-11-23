package Data::Typed::Expression;

use 5.010;
use Text::Balanced qw( );
use Parse::RecDescent;
use Carp 'croak';

use warnings;
use strict;

=head1 NAME

Data::Typed::Expression - Parsing typed expressions

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

sub new {
	my ($class, $str) = @_;
	my @tokens = _split_expr($str);
	my $self = {
		tok => \@tokens,
	};
	return bless $self, $class;
}

sub _split_expr {
	my ($expr) = @_;
	my @resu;
	
	while (length $expr) {
		my ($match, $reminder, $prefix) = Text::Balanced::extract_bracketed($expr,
				'[', qr/[a-zA-Z_0-9]*/);

		if ($match) {
			croak "Can't parse $expr"
				unless length $prefix && $reminder =~ /^(\..+|\+.+|-.*|$)/;
			
			push @resu, $prefix;
			push @resu, [
				_split_expr(substr $match, 1, length($match)-2)
			];
			($expr = $reminder) =~ s/^\.//;
		} elsif ($expr =~ /^(\+|-)(.*)/) {
			push @resu, $1;
			$expr = $2 // '';
		} elsif ($expr =~ /^([a-zA-Z_0-9]+)(\+|-)(.*)$/) {
			push @resu, $1;
			push @resu, $2;
			$expr = $3 // '';
		} else {
			croak "Can't parse $expr" unless $expr =~ /^([a-zA-Z_0-9]+)(\.(.*))?$/;
			push @resu, $1;
			$expr = $3 // '';
		}
	}
		
	@resu;
}

sub make_ast {
	my ($expr) = @_;
	my $grammar = <<'EOT';

{
sub _op {
	if (@_ == 1) {
		return { op => $_[0] };
	} elsif (@_ == 2) {
		return { op => $_[0], arg => $_[1] };
	} else {
		return { op => $_[0], arg => [ @_[1..$#_] ] };
	}
}
}

expression: full_expr /\z/ { $item[-2] }

full_expr:
	  expr_part expr_sep full_expr { _op $item[-2], $item[-3], $item[-1] }
	| expr_part

expr_part:
	  expr_noadd '.' expr_part { _op $item[-2], $item[-3], $item[-1] } 
	| expr_noadd

expr_noadd:
	  '(' full_expr ')' { $item[-2] }
	| indexed_expr
	| var_name
	| const

expr_sep: m{[-+*/]}

indexed_expr: var_name indices { _op '[]', $item[-2], @{$item[-1]} }

indices: index(s)

index: '[' full_expr ']' { $item[-2] }

var_name: /[a-zA-Z_][a-zA-Z_0-9]*/ { _op 'V', $item[-1] }

const: int | double

int: /(\+|-)?\d+(?![\.0-9])/ { _op 'I', $item[-1] }

double: /(\+|-)?\d+(\.\d+)?/ { _op 'D', $item[-1] }

EOT

	my $parser = Parse::RecDescent->new($grammar) or die "Bad grammar: $!";
	my $ast = $parser->expression($expr);
	defined $ast or print "Bad text: $expr\n";
	$ast;
}



1;

