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

sub parse_parameter_str {
	my ($self, $type_str) = @_;
	return $self->structured_type->parse_parameter_str($type_str);
}

sub parameterize {
	my ($self, $parameter_string) = @_;
	my @contained_tcs = $self->parse_parameter_str($parameter_string);
	my $tc_name = $self->name .'['. join(',', map {$_->name} @contained_tcs) .']';
	
	return $self->structured_type->new(
		name => $tc_name,
		parent => $self->parent,
		package_defined_in => __PACKAGE__,
		signature => \@contained_tcs,
	);			
}

1;
