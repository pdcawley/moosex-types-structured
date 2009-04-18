package ## Hide from PAUSE
 MooseX::Meta::TypeConstraint::Structured;

use Moose;
use Devel::PartialDump;
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

has 'constraint_generator' => (
    is=>'ro',
    isa=>'CodeRef',
    predicate=>'has_constraint_generator',
);

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

=head2 validate

Messing with validate so that we can support niced error messages.
=cut

override 'validate' => sub {
    my ($self, @args) = @_;
    my $message = bless {message=>undef}, 'MooseX::Types::Structured::Message';

    if ($self->_compiled_type_constraint->(@args, $message)) {
        ## Everything is good, no error message to return
        return undef;
    } else {
        ## Whoops, need to figure out the right error message
        my $args = Devel::PartialDump::dump(@args);
        if(my $message = $message->{message}) {
            return $self->get_message("$args, Internal Validation Error is: $message");
        } else {
            return $self->get_message($args);
        }
    }
};

=head2 generate_constraint_for ($type_constraints)

Given some type constraints, use them to generate validation rules for an ref
of values (to be passed at check time)

=cut

sub generate_constraint_for {
    my ($self, $type_constraints) = @_;
    return sub {
        my $arg =  shift @_;
        my $constraint_generator = $self->constraint_generator;
        my $result = $constraint_generator->($type_constraints, $arg, $_[0]);
        return $result;
    };
}

=head2 parameterize (@type_constraints)

Given a ref of type constraints, create a structured type.

=cut

sub parameterize {
    
    my ($self, @type_constraints) = @_;
    my $class = ref $self;
    my $name = $self->name .'['. join(',', map {"$_"} @type_constraints) .']';
    my $constraint_generator = $self->__infer_constraint_generator;

    return $class->new(
        name => $name,
        parent => $self,
        type_constraints => \@type_constraints,
        constraint_generator => $constraint_generator,
    );
}

=head2 __infer_constraint_generator

This returns a CODEREF which generates a suitable constraint generator.  Not
user servicable, you'll never call this directly.

=cut

sub __infer_constraint_generator {
    my ($self) = @_;
    if($self->has_constraint_generator) {
        return $self->constraint_generator;
    } else {
        return sub {
            ## I'm not sure about this stuff but everything seems to work
            my $tc = shift @_;
            my $merged_tc = [@$tc, @{$self->parent->type_constraints}];
            $self->constraint->($merged_tc, @_);            
        };
    }    
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
        constraint_generator => $self->__infer_constraint_generator,
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
        $self->parent->equals($other->parent)
            and
        $self->type_constraints_equals($other)
    );
}

sub is_a_type_of {
    my ( $self, $type_or_name ) = @_;
    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    if ( $other->isa(__PACKAGE__) and @{ $other->type_constraints || [] }) {
        if ( $self->parent->is_a_type_of($other->parent) ) {
            return $self->_type_constraints_op_all($other, "is_a_type_of");
        } elsif ( $self->parent->is_a_type_of($other) ) {
            return 1;
            # FIXME compare?
        } else {
            return 0;
        }
    } else {
        return $self->SUPER::is_a_type_of($other);
    }
}

sub is_subtype_of {
    my ( $self, $type_or_name ) = @_;

    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    if ( $other->isa(__PACKAGE__) ) {
        if ( $other->type_constraints and $self->type_constraints ) {
            if ( $self->parent->is_a_type_of($other->parent) ) {
                return (
                    $self->_type_constraints_op_all($other, "is_a_type_of")
                      and
                    $self->_type_constraints_op_any($other, "is_subtype_of")
                );
            } elsif ( $self->parent->is_a_type_of($other) ) {
                return 1;
                # FIXME compare?
            } else {
                return 0;
            }
        } else {
            if ( $self->type_constraints ) {
                if ( $self->SUPER::is_subtype_of($other) ) {
                    return 1;
                } else {
                    return;
                }
            } else {
                return $self->parent->is_subtype_of($other->parent);
            }
        }
    } else {
        return $self->SUPER::is_subtype_of($other);
    }
}

=head2 type_constraints_equals

Checks to see if the internal type contraints are equal.

=cut

sub type_constraints_equals {
    my ( $self, $other ) = @_;
    $self->_type_constraints_op_all($other, "equals");
}

sub _type_constraints_op_all {
    my ($self, $other, $op) = @_;

    return unless $other->isa(__PACKAGE__);

    my @self_type_constraints = @{$self->type_constraints||[]};
    my @other_type_constraints = @{$other->type_constraints||[]};

    return unless @self_type_constraints == @other_type_constraints;

    ## Incoming ay be either arrayref or hashref, need top compare both
    while(@self_type_constraints) {
        my $self_type_constraint = shift @self_type_constraints;
        my $other_type_constraint = shift @other_type_constraints;
        
        $_ = Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_)
          for $self_type_constraint, $other_type_constraint;

        $self_type_constraint->$op($other_type_constraint) or return;
    }
    
    return 1; ##If we get this far, everything is good.
}

sub _type_constraints_op_any {
    my ($self, $other, $op) = @_;

    return unless $other->isa(__PACKAGE__);

    my @self_type_constraints = @{$self->type_constraints||[]};
    my @other_type_constraints = @{$other->type_constraints||[]};

    return unless @self_type_constraints == @other_type_constraints;

    ## Incoming ay be either arrayref or hashref, need top compare both
    while(@self_type_constraints) {
        my $self_type_constraint = shift @self_type_constraints;
        my $other_type_constraint = shift @other_type_constraints;
        
        $_ = Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_)
          for $self_type_constraint, $other_type_constraint;
        
        return 1 if $self_type_constraint->$op($other_type_constraint);
    }

    return 0;
}

=head2 get_message

Give you a better peek into what's causing the error.  For now we stringify the
incoming deep value with L<Devel::PartialDump> and pass that on to either your
custom error message or the default one.  In the future we'll try to provide a
more complete stack trace of the actual offending elements

=cut

around 'get_message' => sub {
    my ($get_message, $self, $value) = @_;
    $value = Devel::PartialDump::dump($value)
     if ref $value;
    return $self->$get_message($value);
};

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<Moose::Meta::TypeConstraint>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
