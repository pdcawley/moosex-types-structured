package MooseX::Meta::TypeConstraint::Structured::Named;

use Moose;
use Moose::Meta::TypeConstraint ();
use Moose::Util::TypeConstraints;

extends 'Moose::Meta::TypeConstraint';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Named - Structured Type Constraints

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

Named structured Constraints expect the internal constraints to be in keys or
fields similar to what we expect in a HashRef.

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
    isa=>'HashRef[Moose::Meta::TypeConstraint]',
    required=>1,
);

=head2 optional_signature

This is a signature of internal contraints for the contents of the outer
contraint container.  These are optional constraints.

=cut

has 'optional_signature' => (
    is=>'ro',
    isa=>'HashRef[Moose::Meta::TypeConstraint]',
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
        if(ref $args eq 'HASH') {
            %$args
        } else {
            confess 'Signature must be an HashRef type';
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
        my %args = $self->_normalize_args(shift);
        my @signature = keys %{$self->signature};
        my @ptional_signature = keys %{$self->optional_signature}
         if $self->has_optional_signature;
        
        ## First make sure all the required type constraints match        
        while( my $type_constraint_key = shift @signature) {
            my $type_constraint = $self->signature->{$type_constraint_key};
            if(my $error = $type_constraint->validate($args{$type_constraint_key})) {
                confess $error;
            }
            delete $args{$type_constraint_key};
        }
        
        ## Now test the option type constraints.
        while( my $arg_key = keys %args) {
            my $optional_type_constraint = $self->signature->{$arg_key};
            if(my $error = $optional_type_constraint->validate($args{$arg_key})) {
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
    
    foreach my $idx (keys %{$self->signature}) {
        my $this = $self->signature->{$idx};
        my $that = $compared_type_constraint->signature->{$idx};
        return unless $this->equals($that);
    }
    
    if($self->has_optional_signature) {
        foreach my $idx (keys %{$self->optional_signature}) {
            my $this = $self->optional_signature->{$idx};
            my $that = $compared_type_constraint->optional_signature->{$idx};
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
