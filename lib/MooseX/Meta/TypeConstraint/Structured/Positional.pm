package MooseX::Meta::TypeConstraint::Structured::Positional;

use Moose;
use Moose::Meta::TypeConstraint ();
use Moose::Util::TypeConstraints;

extends 'Moose::Meta::TypeConstraint';
with 'MooseX::Meta::TypeConstraint::Role::Structured';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Positional - Structured Type Constraints

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

Structured type constraints let you assign an internal pattern of type
constraints to a 'container' constraint.  The goal is to make it easier to
declare constraints like "ArrayRef[Int, Int, Str]" where the constraint is an
ArrayRef of three elements and the internal constraint on the three is Int, Int
and Str.

To accomplish this, we add an attribute to the base L<Moose::Meta::TypeConstraint>
to hold a L</signature>, which is a reference to a pattern of type constraints.
We then override L</constraint> to check our incoming value to the attribute
against this signature pattern.

Positionally structured Constraints expect the internal constraints to be in
'positioned' or ArrayRef style order.

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

has '+signature' => (
    isa=>'ArrayRef[Moose::Meta::TypeConstraint]',
);

=head2 optional_signature

This is a signature of internal contraints for the contents of the outer
contraint container.  These are optional constraints.

=cut

has 'optional_signature' => (
    is=>'ro',
    isa=>'ArrayRef[Moose::Meta::TypeConstraint]',
    predicate=>'has_optional_signature',
);

=head1 METHODS

This class defines the following methods.

=head2 _normalize_args

Get arguments into a known state or die trying.  Ideally we try to make this
into a HashRef so we can match it up with the L</signature> HashRef.

=cut

sub _normalize_args {
    my ($self, $args) = @_;
    if(defined $args) {
        if(ref $args eq 'ARRAY') {
            @$args
        } else {
            confess 'Signature must be an ArrayRef type';
        }
    } else {
        confess 'Signature cannot be empty';
    }
}
    
=head2 constraint

The constraint is basically validating the L</signature> against the incoming

=cut

sub constraint {
    my $self = shift;
    return sub {
        my @args = $self->_normalize_args(shift);
        my @signature = @{$self->signature};
        my @optional_signature = @{$self->optional_signature}
         if $self->has_optional_signature;
        
        ## First make sure all the required type constraints match        
        while( my $type_constraint = shift @signature) {
            if(my $error = $type_constraint->validate(shift @args)) {
                confess $error;
            }            
        }
        
        ## Now test the option type constraints.
        while( my $arg = shift @args) {
            my $optional_type_constraint = shift @optional_signature;
            if(my $error = $optional_type_constraint->validate($arg)) {
                confess $error;
            }              
        }
        
        ## If we got this far we passed!
        return 1;
    };
}

=head2 signature_equals

Check that the signature equals another signature.

=cut

sub signature_equals {
    my ($self, $compared_type_constraint) = @_;
    
    foreach my $idx (0..$#{$self->signature}) {
        my $this = $self->signature->[$idx];
        my $that = $compared_type_constraint->signature->[$idx];
        return unless $this->equals($that);
    }
    
    if($self->has_optional_signature) {
        foreach my $idx (0..$#{$self->optional_signature}) {
            my $this = $self->optional_signature->[$idx];
            my $that = $compared_type_constraint->optional_signature->[$idx];
            return unless $this->equals($that);
        }        
    }

    return 1;
}

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

no Moose; 1;
