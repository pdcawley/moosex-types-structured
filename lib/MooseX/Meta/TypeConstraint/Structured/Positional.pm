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
        my @optional_signature;
        
        if($signature[-1]->isa('MooseX::Meta::TypeConstraint::Structured::Optional')) {
            my $optional = pop @signature;
            @optional_signature = @{$optional->signature};
        }
        
        ## First make sure all the required type constraints match        
        while( my $type_constraint = shift @signature) {
            if(my $error = $type_constraint->validate(shift @args)) {
                confess $error;
            }            
        }
        
        ## Now test the option type constraints.
        while( my $arg = shift @args) {
            if(my $optional_type_constraint = shift @optional_signature) {
                if(my $error = $optional_type_constraint->validate($arg)) {
                    confess $error;
                }                              
            } else {
                confess "Too Many arguments for the available type constraints";
            }
        }
        
        ## If we got this far we passed!
        return 1;
    };
}

=head2 _parse_type_parameter ($str)

Given a $string that is the parameter information part of a parameterized
constraint, parses it for internal constraint information.  For example:

	MyType[Int,Int,Str]

has a parameter string of "Int,Int,Str" (whitespace will automatically be 
removed during normalization that happens in L<Moose::Util::TypeConstraints>)
and we need to convert that to ['Int','Int','Str'] which then has any type
constraints converted to true objects.

=cut

{
    use re "eval";

    my $any;
    my $valid_chars = qr{[\w:]};
    my $type_atom   = qr{ $valid_chars+ };
    
    my $type                = qr{  $valid_chars+  (?: \[  (??{$any})  \] )? }x;
    my $type_capture_parts  = qr{ ($valid_chars+) (?: \[ ((??{$any})) \] )? }x;
    my $type_with_parameter = qr{  $valid_chars+      \[  (??{$any})  \]    }x;
    
    my $op_union = qr{ \s* \| \s* }x;
    my $union    = qr{ $type (?: $op_union $type )+ }x;
    
    ## New Stuff for structured types.
    my $comma = qr{,};
    my $indirection = qr{=>};
    my $divider_ops = qr{ $comma | $indirection }x;
    my $structure_divider = qr{\s* $divider_ops \s*}x;    
    my $structure_elements = qr{ $valid_chars+ $structure_divider $type | $union }x;

    $any = qr{  $union | $structure_elements+ | $type }x;

	sub _parse_type_parameter {
		my ($class, $type_str) = @_;
        {
            $any;
            my @type_strs = ($type_str=~m/$union | $type/gx);
            return map {
                Moose::Util::TypeConstraints::find_or_create_type_constraint($_);
            } @type_strs;
        }
	}
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
