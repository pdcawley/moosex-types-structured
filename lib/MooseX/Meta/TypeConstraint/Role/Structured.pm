package MooseX::Meta::TypeConstraint::Role::Structured;

use Moose::Role;

=head1 NAME

MooseX::Meta::TypeConstraint::Role::Structured - Structured Type Constraints

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

STUB - TBD

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

=head1 METHODS

This class defines the following methods.

=head2 _normalize_args

Get arguments into a known state or die trying.  Ideally we try to make this
into a HashRef so we can match it up with the L</signature> HashRef.

=cut

    
=head2 constraint

The constraint is basically validating the L</signature> against the incoming

=cut

=head2 equals

modifier to make sure equals descends into the L</signature>

=cut

=head2 signature_equals

Check that the signature equals another signature.

=cut

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
