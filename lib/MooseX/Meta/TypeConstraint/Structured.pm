package ## Hide from PAUSE
 MooseX::Meta::TypeConstraint::Structured;

use Moose;
use Moose::Util::TypeConstraints ();
use MooseX::Meta::TypeCoercion::Structured;
extends 'Moose::Meta::TypeConstraint';

=head1 NAME

MooseX::Meta::TypeConstraint::Structured - Structured type constraints.

=head1 DESCRIPTION

A structure is a set of L<Moose::Meta::TypeConstraint> that are 'aggregated' in
such a way as that they are all applied to an incoming list of arguments.  The
idea here is that a Type Constraint could be something like, "An Int followed by
an Int and then a Str" and that this could be done so with a declaration like:

    Tuple[Int,Int,Str]; ## Example syntax
    
So a structure is a list of Type constraints (the "Int,Int,Str" in the above
example) which are intended to function together.

=head1 ATTRIBUTES

This class defines the following attributes.

=head2 type_constraints

A list of L<Moose::Meta::TypeConstraint> objects.

=cut

has 'type_constraints' => (
    is=>'ro',
    isa=>'Ref',
    predicate=>'has_type_constraints',
);

=head2 constraint_generator

A subref or closure that contains the way we validate incoming values against
a set of type constraints.

=cut

has 'constraint_generator' => (is=>'ro', isa=>'CodeRef');

=head1 METHODS

This class defines the following methods.

=head2 new

Initialization stuff.

=cut

around 'new' => sub {
    my ($new, $class, @args)  = @_;
    my $self = $class->$new(@args);
    $self->coercion(MooseX::Meta::TypeCoercion::Structured->new(
        type_constraint => $self,
    ));
    return $self;
};

=head2 generate_constraint_for ($type_constraints)

Given some type constraints, use them to generate validation rules for an ref
of values (to be passed at check time)

=cut

sub generate_constraint_for {
    my ($self, $type_constraints) = @_;
    return sub {
        my $constraint_generator = $self->constraint_generator;
        return $constraint_generator->($type_constraints, @_);
    };
}

=head2 parameterize (@type_constraints)

Given a ref of type constraints, create a structured type.

=cut

sub parameterize {
    my ($self, @type_constraints) = @_;
    my $class = ref $self;
    my $name = $self->name .'['. join(',', map {"$_"} @type_constraints) .']';

    return $class->new(
        name => $name,
        parent => $self,
        type_constraints => \@type_constraints,
        constraint_generator => $self->constraint_generator || sub {
            my $tc = shift @_;
            my $merged_tc = [@$tc, @{$self->parent->type_constraints}];
            $self->constraint->($merged_tc, @_);
        },
    );
}

=head2 compile_type_constraint

hook into compile_type_constraint so we can set the correct validation rules.

=cut

around 'compile_type_constraint' => sub {
    my ($compile_type_constraint, $self, @args) = @_;
    
    if($self->has_type_constraints) {
        my $type_constraints = $self->type_constraints;
        my $constraint = $self->generate_constraint_for($type_constraints);
        $self->_set_constraint($constraint);        
    }

    return $self->$compile_type_constraint(@args);
};

=head2 create_child_type

modifier to make sure we get the constraint_generator

=cut

around 'create_child_type' => sub {
    my ($create_child_type, $self, %opts) = @_;
    return $self->$create_child_type(
        %opts,
        constraint_generator => $self->constraint_generator,
    );
};

=head2 is_a_type_of

=head2 is_subtype_of

=head2 equals

Override the base class behavior.

=cut

sub equals {
    my ( $self, $type_or_name ) = @_;
    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    return unless $other->isa(__PACKAGE__);
    
    return (
        $self->type_constraints_equals($other)
            and
        $self->parent->equals( $other->parent )
    );
}

=head2 type_constraints_equals

Checks to see if the internal type contraints are equal.

=cut

sub type_constraints_equals {
    my ($self, $other) = @_;
    my @self_type_constraints = @{$self->type_constraints||[]};
    my @other_type_constraints = @{$other->type_constraints||[]};
    
    ## Incoming ay be either arrayref or hashref, need top compare both
    while(@self_type_constraints) {
        my $self_type_constraint = shift @self_type_constraints;
        my $other_type_constraint = shift @other_type_constraints
         || return; ## $other needs the same number of children.
        
        if( ref $self_type_constraint) {
            $self_type_constraint->equals($other_type_constraint)
             || return; ## type constraints obviously need top be equal
        } else {
            $self_type_constraint eq $other_type_constraint
             || return; ## strings should be equal
        }

    }
    
    return 1; ##If we get this far, everything is good.
}

=head2 get_message

May want to override this to set a more useful error message

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<Moose::Meta::TypeConstraint>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;