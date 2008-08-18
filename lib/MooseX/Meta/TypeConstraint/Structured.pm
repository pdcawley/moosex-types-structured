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

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 parent

additional details on the inherited parent attribute

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has 'signature' => (
    is=>'ro',
    isa=>'Ref',
    required=>1,
);

=head1 METHODS

This class defines the following methods.

=head2 _normalize_args

Get arguments into a known state or die trying

=cut

sub _normalize_args {
    my ($self, $args) = @_;
    if(defined $args && ref $args eq 'ARRAY') {
        return @{$args};
    } else {
        confess 'Arguments not ArrayRef as expected.';
    }
}
    
=head2 constraint

The constraint is basically validating the L</signature> against the incoming

=cut

sub constraint {
    my $self = shift;
    return sub {
        my @args = $self->_normalize_args(shift);
        foreach my $idx (0..$#args) {
            if(my $error = $self->signature->[$idx]->validate($args[$idx])) {
                confess $error;
            }
        } 1;        
    };
}

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

no Moose; 1;
