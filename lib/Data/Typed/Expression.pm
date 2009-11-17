package Data::Typed::Expression;

use warnings;
use strict;

use Text::Balanced 'extract_bracketed';
use 5.010;

our $VERSION = '0.001';

sub split_expr {

	my ($expr) = @_;
	my @resu;
	
	while (length $expr) {
		my ($match, $reminder, $prefix) = extract_bracketed($expr, '[', qr/[a-zA-Z_0-9]*/);

		if ($match) {
			die "Can't parse $expr"
				unless length $prefix && $reminder =~ /^(\..+|$)/;
			
			push @resu, $prefix;
			push @resu, [
				split_expr(substr $match, 1, length($match)-2)
			];
			($expr = $reminder) =~ s/^\.//;
		} else {
			die "Can't parse $expr" unless $expr =~ /^([a-zA-Z_0-9]+)(\.(.*))?$/;
			push @resu, $1;
			$expr = $3 // '';
		}
	}
		
	@resu;
}

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

sub validate_typed_expr {
	my @split_expr = @_;
	return '' unless @split_expr;

	my $curr_var = shift @split_expr;
	die "Undefined var: $curr_var" unless exists $vars->{$curr_var};
	my $curr_type = $vars->{$curr_var};
	
	for (@split_expr) {
		if (ref $_) {
			die "Tried to index non-array type ($curr_type)"
				unless $curr_type =~ /\[\]$/;
			my $sub_type = validate_typed_expr(@$_);
			die "Can't index $curr_type with non-int ($sub_type) type"
				if $sub_type ne 'int';
			$curr_type =~ s/\[\]$//;
		} else {
			die "Tried to get elements of simple type ($curr_type)"
				unless ref $types->{$curr_type};
			die "Type $curr_type has no element named $_"
				unless exists $types->{$curr_type}{$_};
			$curr_type = $types->{$curr_type}{$_};
		}
	}
	return $curr_type;
}

#use Data::Dumper;

#my @split_expr = split_expr($ARGV[0]);
#say validate_typed_expr(@split_expr);

1;

