package MooseX::Meta::TypeConstraint::Role::Structured;

use Moose::Role;
use Moose::Util::TypeConstraints;
requires qw(_normalize_args signature_equals);

=head1 NAME

MooseX::Meta::TypeConstraint::Role::Structured - Structured Type Constraints

=head1 DESCRIPTION

This Role defines the interface and basic behavior of Structured Type Constraints.

=head1 TYPES

The following types are defined in this class.

=head2 Moose::Meta::TypeConstraint

Used to make sure we can properly validate incoming signatures.

=cut

class_type 'Moose::Meta::TypeConstraint';

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has 'signature' => (
    is=>'ro',
    isa=>'Ref',
    required=>1,
);

=head2 optional_signature

This is a signature of internal contraints for the contents of the outer
contraint container.  These are optional constraints.

=cut

has 'optional_signature' => (
    is=>'ro',
    isa=>'Ref',
    predicate=>'has_optional_signature',
);

=head1 METHODS

This class defines the following methods.

=head2 equals

modifier to make sure equals descends into the L</signature>

=cut

around 'equals' => sub {
    my ($equals, $self, $compared_type_constraint) = @_;
    
    ## Make sure we are comparing typeconstraints of the same base class
    return unless $compared_type_constraint->isa(__PACKAGE__);
    
    ## Make sure the base equals is also good
    return unless $self->$equals($compared_type_constraint);
    
    ## Make sure the signatures match
    return unless $self->signature_equals($compared_type_constraint);
   
    ## If we get this far, the two are equal
    return 1;
};

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
