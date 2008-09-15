package MooseX::Meta::TypeConstraint::Structured::Optional;

use Moose;
use Moose::Meta::TypeConstraint ();

#extends 'Moose::Meta::TypeConstraint';
extends 'MooseX::Meta::TypeConstraint::Structured::Positional';
with 'MooseX::Meta::TypeConstraint::Role::Structured';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Optional - Structured Type Constraints

=head1 SYNOPSIS

The follow is example usage:

    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured::Optional;
    
    my @options = ('Str', 'Int');
    
    my $tc = MooseX::Meta::TypeConstraint::Structured::Optional->new(
        name => 'Dict',
        parent => find_type_constraint('ArrayRef'),
        signature => [map {
            find_type_constraint($_);
        } @options],
    );
    
=head1 DESCRIPTION

Optional Type Constraints are additional constraints on a 'base' structured
type constraint which extends those constraints with additional optional
fields.  Basically this constraint get's it's constraint logic and args
from a a Structured Type Constraint that contains it.  So basically:

	MyType[Int,Str,Optional[Int, Int]]

In this example, the structured Type constraint 'MyType' is the container for
this Optional type called 'Optional'.  What will happen here is that the
MyType will get the first elements for validation and a third one will go
to optional.  Optional will 'inline' itself so that you can validate with:

	->validate(1,'hello',2,3);
	->validate(1,'hello',2);
	->validate(1,'hello');	

and not:

	->validate(1,'hello',[2,3]]);
	->validate(1,'hello',[2]]);	

as you might expect.  Basically it sucks up args to the length of it's declared
type constraints.  So Optional args are validated against the definition, but if
they are missing this does not cause a validation error.

Please keep in mind the type constraint names given in this example are for
example use only and any similarity between them, actual Type Constraints and
package names are coincidental.

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 containing_type_constraint ($structured_type_constraint)

This is the type constraint that contains the Optional parameters.

=cut

#has 'containing_type_constraint' => (
#	is=>'ro', 
#	does=>'MooseX::Meta::TypeConstraint::Role::Structured',
#	required=>1,
#);

=head2 signature

This is a signature of internal contraints for the contents of the outer
contraint container.

=cut

has '+signature' => (isa=>'ArrayRef[Moose::Meta::TypeConstraint]');

=head1 METHODS

This class defines the following methods.

=head2 _normalize_args

Get arguments into a known state or die trying.  Ideally we try to make this
into a HashRef so we can match it up with the L</signature> HashRef.  This gets
delegated to the containing class (L</containing_type_constraint>).

=cut

#sub _normalize_args {
#    return shift->containing_type_constraint->_normalize_args(@_);
#}
    
=head2 constraint

The constraint is basically validating the L</signature> against the incoming

=cut

#sub constraint {
#	return 1;
 #   return shift->containing_type_constraint->constraint(@_);
#}

=head2 _parse_type_parameter ($str)

Given a $string that is the parameter information part of a parameterized
constraint, parses it for internal constraint information.  This is delegated
to the containing class.

=cut

#sub _parse_type_parameter {
#    return shift->containing_type_constraint->_parse_type_parameter(@_);
#}


=head2 signature_equals

Check that the signature equals another signature.  Delegated to the containing
class.

=cut

#sub signature_equals {
#    return shift->containing_type_constraint->signature_equals(@_);
#}

=head1 AUTHOR

John James Napiorkowski <jjnapiork@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

no Moose; 1;
