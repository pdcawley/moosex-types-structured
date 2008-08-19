package MooseX::Meta::TypeConstraint::Structured;

use 5.8.8; ## Minimum tested Perl Version
use Moose;
use Moose::Util::TypeConstraints;

extends 'Moose::Meta::TypeConstraint';

our $AUTHORITY = 'cpan:JJNAPIORK';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured - Structured Type Constraints

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

=head1 SUBTYPES

The following subtypes and coercions are defined in this class.

=head2 MooseX::Meta::TypeConstraint::Structured::Signature

This is a type constraint to normalize the incoming L</signature>.

=cut

subtype 'MooseX::Meta::TypeConstraint::Structured::Signature',
    as 'HashRef[Object]',
    where {
        my %signature = %$_;
        foreach my $key (keys %signature) {
            $signature{$key}->isa('Moose::Meta::TypeConstraint');
        } 1;
    };
 
coerce 'MooseX::Meta::TypeConstraint::Structured::Signature',
    from 'ArrayRef[Object]',
    via {
        my @signature = @$_;
        my %hashed_signature = map { $_ => $signature[$_] } 0..$#signature;
        \%hashed_signature;
    };

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has 'signature' => (
    is=>'ro',
    isa=>'MooseX::Meta::TypeConstraint::Structured::Signature',
    coerce=>1,
    required=>1,
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
            return map { $_ => $args->[$_] } (0..$#$args);
        } elsif (ref $args eq 'HASH') {
            return %$args;
        } else {
            confess 'Signature must be a reference';
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
        foreach my $idx (keys %{$self->signature}) {
            my $type_constraint = $self->signature->{$idx};
            if(my $error = $type_constraint->validate($args{$idx})) {
                confess $error;
            }
        } 1;        
    };
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
   
    return 1;
}

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

no Moose; 1;
