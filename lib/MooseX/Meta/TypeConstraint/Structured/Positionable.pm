package MooseX::Meta::TypeConstraint::Structured::Positionable;

use strict;
use warnings;

use metaclass;

use base 'Moose::Meta::TypeConstraint::Parameterizable';
use Moose::Util::TypeConstraints ();
use MooseX::Meta::TypeConstraint::Structured::Positional;


sub parse_parameter_str {
    my ($self, @type_strs) = @_; warn '.........................';
    return map {Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_)} @type_strs;
}

sub parameterize {
	my ($self, @contained_tcs) = @_; warn ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,';
	my $tc_name = $self->name .'['. join(', ', map {$_->name} @contained_tcs) .']';
	
	return MooseX::Meta::TypeConstraint::Structured::Positional->new(
		name => $tc_name,
		parent => find_type_constraint('ArrayRef'),
		package_defined_in => __PACKAGE__,
		signature => \@contained_tcs,
	);			

}


1;
