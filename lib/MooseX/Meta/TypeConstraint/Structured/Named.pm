package MooseX::Meta::TypeConstraint::Structured::Named;

use Moose;
use Moose::Meta::TypeConstraint ();

extends 'Moose::Meta::TypeConstraint';
with 'MooseX::Meta::TypeConstraint::Role::Structured';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Named - Structured Type Constraints

=head1 SYNOPSIS

The follow is example usage:

    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured::Named;
    
    my %required = (key1='Str', key2=>'Int');
    my %optional = (key3=>'Object');
    
    my $tc = MooseX::Meta::TypeConstraint::Structured::Named->new(
        name => 'Dict',
        parent => find_type_constraint('HashRef'),
        package_defined_in => __PACKAGE__,
        signature => {map {
            $_ => find_type_constraint($required{$_});
        } keys %required},
        optional_signature => {map {
            $_ => find_type_constraint($optional{$_});
        } keys %optional},
    );

=head1 DESCRIPTION

Named structured Constraints expect the internal constraints to be in keys or
fields similar to what we expect in a HashRef.  Basically, this allows you to
easily add type constraint checks against values in the wrapping HashRef
identified by the key name.

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has '+signature' => (isa=>'HashRef[Moose::Meta::TypeConstraint]');

=head2 optional_signature

This is a signature of internal contraints for the contents of the outer
contraint container.  These are optional constraints.

=cut

has '+optional_signature' => (isa=>'HashRef[Moose::Meta::TypeConstraint]');

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
        
        ## First make sure all the required type constraints match        
        foreach my $sig_key (keys %{$self->signature}) {
            my $type_constraint = $self->signature->{$sig_key};
            if(my $error = $type_constraint->validate($args{$sig_key})) {
                confess $error;
            } else {
                delete $args{$sig_key};
            }
        }
        
        ## Now test the option type constraints.
        foreach my $arg_key (keys %args) {
            my $optional_type_constraint = $self->optional_signature->{$arg_key};
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



=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

no Moose; 1;
