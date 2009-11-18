package Data::Typed::Expression::Env;

use 5.010;
use Text::Balanced 'extract_bracketed';
use Carp 'croak';

use warnings;
use strict;

our $VERSION = '0.001';

sub new {
	my ($class, $types, $vars) = @_;
	$vars //= { };
	$types //= { };
	my $self = {
		t => $types,
		v => $vars
	};
	
	return bless $self, $class;
}

sub get_type_def {
	return $_[0]->{t}{$_[1]};
}

sub get_var_type {
	return $_[0]->{v}{$_[1]};
}

sub validate {
	return $_[0]->_validate_tokens($_[1]->{tok});
}

sub _check_const_type {
	return 'int' if $_[0] =~ /^\d+$/;
	return 'double' if $_[0] =~ /^\d+\.\d+$/;
	
	undef;
}

sub _validate_tokens {
	my ($self, $split_expr) = @_;

	return '' unless @$split_expr;

	my $curr_var = shift @$split_expr;
	my $curr_type = _check_const_type $curr_var;
	unless (defined $curr_type) {
		croak "Undefined var: $curr_var" unless exists $self->{v}{$curr_var};
		$curr_type = $self->{v}{$curr_var};
	}
	
	for (@$split_expr) {
		if (ref $_) {
			croak "Tried to index non-array type ($curr_type)"
				unless $curr_type =~ /\[\]$/;
			my $sub_type = $self->_validate_tokens($_);
			croak "Can't index $curr_type with non-int ($sub_type) type"
				if $sub_type ne 'int';
			$curr_type =~ s/\[\]$//;
		} else {
			croak "Tried to get elements of simple type ($curr_type)"
				unless ref $self->{t}{$curr_type};
			croak "Type $curr_type has no element named $_"
				unless exists $self->{t}{$curr_type}{$_};
			$curr_type = $self->{t}{$curr_type}{$_};
		}
	}
	return $curr_type;
}

1;

