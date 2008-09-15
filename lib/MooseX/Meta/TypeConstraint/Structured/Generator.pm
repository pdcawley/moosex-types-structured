package MooseX::Meta::TypeConstraint::Structured::Generator;

use strict;
use warnings;

use metaclass;

use base 'Moose::Meta::TypeConstraint';
use Moose::Util::TypeConstraints ();

__PACKAGE__->meta->add_attribute('structured_type' => (
    accessor  => 'structured_type',
    predicate => 'has_structured_type',
));

sub _parse_type_parameter {
	my ($self, $type_str) = @_;
	return $self->structured_type->_parse_type_parameter($type_str);
}

sub parameterize {
	my ($self, $parameter_string) = @_;
	my @contained_tcs = $self->_parse_type_parameter($parameter_string);
	my $tc_name = $self->name .'['. join(',', map {$_->name} @contained_tcs) .']';
	
	return $self->structured_type->new(
		name => $tc_name,
		parent => $self->parent,
		package_defined_in => __PACKAGE__,
		signature => \@contained_tcs, 
	);			
}

1;
