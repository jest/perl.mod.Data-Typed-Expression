package Data::Typed::Expression;

use 5.010;
use Text::Balanced qw( );
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
				unless length $prefix && $reminder =~ /^(\..+|$)/;
			
			push @resu, $prefix;
			push @resu, [
				_split_expr(substr $match, 1, length($match)-2)
			];
			($expr = $reminder) =~ s/^\.//;
		} else {
			croak "Can't parse $expr" unless $expr =~ /^([a-zA-Z_0-9]+)(\.(.*))?$/;
			push @resu, $1;
			$expr = $3 // '';
		}
	}
		
	@resu;
}

1;

