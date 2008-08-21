package MooseX::Meta::TypeConstraint::Structured::Positional;

use Moose;
use Moose::Meta::TypeConstraint ();

extends 'Moose::Meta::TypeConstraint';
with 'MooseX::Meta::TypeConstraint::Role::Structured';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Positional - Structured Type Constraints

=head1 SYNOPSIS

The follow is example usage:

    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured::Positional;
    
    my @required = ('Str', 'Int');
    my @optional = ('Object');
    
    my $tc = MooseX::Meta::TypeConstraint::Structured::Positional->new(
        name => 'Dict',
        parent => find_type_constraint('ArrayRef'),
        signature => [map {
            find_type_constraint($_);
        } @required],
        optional_signature => [map {
            find_type_constraint($_);
        } @optional],
    );
    
=head1 DESCRIPTION

Positionally structured Constraints expect the internal constraints to be in
'positioned' or ArrayRef style order.  This allows you to add type constraints
to the internal values of the Arrayref.

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has '+signature' => (isa=>'ArrayRef[Moose::Meta::TypeConstraint]');

=head2 optional_signature

This is a signature of internal contraints for the contents of the outer
contraint container.  These are optional constraints.

=cut

has '+optional_signature' => (isa=>'ArrayRef[Moose::Meta::TypeConstraint]');

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

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

no Moose; 1;
