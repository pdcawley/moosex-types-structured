package MooseX::Meta::TypeConstraint::Structured::Positionable;

use strict;
use warnings;

use metaclass;

use base 'Moose::Meta::TypeConstraint::Parameterizable';
use Moose::Util::TypeConstraints ();
use MooseX::Meta::TypeConstraint::Structured::Positional;

    my $comma = qr{,};
    my $indirection = qr{=>};
    my $divider_ops = qr{ $comma | $indirection }x;
    my $structure_divider = qr{\s* $divider_ops \s*}x;

sub parse_parameter_str {
    my ($self, $type_str) = @_;
	my @type_strs = split($structure_divider, $type_str);
    return map {Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_)} @type_strs;
}

sub parameterize {
	my ($self, @contained_tcs) = @_;
	my $tc_name = $self->name .'['. join(',', map {$_->name} @contained_tcs) .']';
	
	return MooseX::Meta::TypeConstraint::Structured::Positional->new(
		name => $tc_name,
		parent => Moose::Util::TypeConstraints::find_type_constraint('ArrayRef'),
		package_defined_in => __PACKAGE__,
		signature => \@contained_tcs,
	);			
}


1;
