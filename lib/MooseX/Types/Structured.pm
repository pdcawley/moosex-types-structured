package MooseX::Types::Structured;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Meta::TypeConstraint::Structured;
use MooseX::Types -declare => [qw(Dict Tuple)];

	
our $VERSION = '0.01';
our $AUTHORITY = 'cpan:JJNAPIORK';

=head1 NAME

MooseX::Types::Structured; Structured Type Constraints for Moose

=head1 SYNOPSIS

The following is example usage for this module.  You can define a class that has
an attribute with a structured type like so:

	package MyApp::MyClass;
	
	use Moose;
	use MooseX::Types::Moose qw(Str Int);
	use MooseX::Types::Structured qw(Dict Tuple);
	
	has name => (isa=>Dict[first_name=>Str, last_name=>Str]);
	
Then you can instantiate this class with something like:

	my $instance = MyApp::MyClass->new(
		name=>{first_name=>'John', last_name=>'Napiorkowski'},
	);

But all of these would cause an error:

	my $instance = MyApp::MyClass->new(name=>'John');
	my $instance = MyApp::MyClass->new(name=>{first_name=>'John'});
	my $instance = MyApp::MyClass->new(name=>{first_name=>'John', age=>39});

Please see the test cases for more examples.

=head1 DESCRIPTION

This type library enables structured type constraints. Basically, this is very
similar to parameterized constraints that are built into the core Moose types,
except that you are allowed to define the container's entire structure.  For
example, you could define a parameterized constraint like so:

	subtype HashOfInts, as Hashref[Int];

which would constraint a value to something like [1,2,3,...] and so one.  A
structured constraint like so:

	subtype StringFollowedByInt, as Tuple[Str,Int];
	
would constrain it's value to something like ['hello', 111];

These structures can be as simple or elaborate as you wish.  You can even
combine various structured, parameterized and simple constraints all together:

	subtype crazy, as Tuple[Int, Dict[name=>Str, age=>Int], ArrayRef[Int]];
	
Which would match "[1, {name=>'John', age=>25},[10,11,12]]".

You should exercise some care as to whether or not your complex structured
constraints would be better off contained by a real object as in the following
example:

	{
		package MyApp::MyStruct;
		use Moose;
		
			has $_ for qw(name age);
		
		package MyApp::MyClass;
		use Moose;
		
			has person => (isa=>'MyApp::MyStruct');		
	}

	my $instance = MyApp::MyClass
		->new( person=>MyApp::MyStruct->new(name=>'John', age=>39) );
	
This method may take some additional time to setup but will give you more
flexibility.  However, structured constraints are highly compatible with this
method, granting some interesting possibilities for coercion.  Try:

	subtype 'MyStruct',
	 as 'MyApp::MyStruct';
	 
	coerce 'MyStruct',
	 from (Dict[name=>Str, age=>Int]),
	 via {
		MyApp::MyStruct->new(%$_);
	 },
	 from (Dict[last_name=>Str, first_name=>Str, dob=>DateTime]),
	 via {
		my $name = $_->{first_name} .' '. $_->{last_name};
		my $age = DateTime->now - $_->{dob};
		MyApp::MyStruct->new(
			name=>$name,
			age=>$age->years );
	 };
	 
=head2 Subtyping a structured subtype

You need to exercise some care when you try to subtype a structured type
as in this example:

	subtype Person,
	 as Dict[name=>Str, age=>iIt];
	 
	subtype FriendlyPerson,
	 as Person[name=>Str, age=>Int, totalFriends=>Int];
	 
This will actually work BUT you have to take care that the subtype has a
structure that does not contradict the structure of it's parent.  For now the
above works, but I will probably clarify how this works at a future point, so
it's recommended to avoid (should not realy be needed so much anyway).  For
now this is supported in an EXPERIMENTAL way.  In the future we will probably
clarify how to augment existing structured types.

=head2 Coercions

Coercions currently work for 'one level' deep.  That is you can do:

	subtype Person,
     as Dict[name=>Str, age=>Int];

    subtype Fullname,
     as Dict[first=>Str, last=>Str];
	 
	coerce Person,
	 from BlessedPersonObject,
	 via { +{name=>$_->name, age=>$_->age} },
	 from ArrayRef,
	 via { +{name=>$_->[0], age=>$_->[1] },
     from Dict[fullname=>Fullname, dob=>DateTime],
     via {
		my $age = $_->dob - DateTime->now;
		+{
			name=> $_->{fullname}->{first} .' '. $_->{fullname}->{last},
			age=>$age->years
		}
     };
	 
And that should just work as expected.  However, if there are any 'inner'
coercions, such as a coercion on 'Fullname' or on 'DateTime', that coercion
won't currently get activated.

Please see the test '07-coerce.t' for a more detailed example.

=head1 TYPE CONSTRAINTS

This type library defines the following constraints.

=head2 Tuple[@constraints]

This defines an arrayref based constraint which allows you to validate a specific
list of constraints.  For example:

	Tuple[Int,Str]; ## Validates [1,'hello']
	Tuple[Str|Object, Int]; ##Validates ['hello', 1] or [$object, 2]

=head2 Dict [%constraints]

This defines a hashref based constraint which allowed you to validate a specific
hashref.  For example:

	Dict[name=>Str, age=>Int]; ## Validates {name=>'John', age=>39}

=cut

Moose::Util::TypeConstraints::get_type_constraint_registry->add_type_constraint(
	MooseX::Meta::TypeConstraint::Structured->new(
		name => "MooseX::Types::Structured::Tuple" ,
		parent => find_type_constraint('ArrayRef'),
		constraint_generator=> sub {
			## Get the constraints and values to check
			my @type_constraints = @{shift @_};            
			my @values = @{shift @_};
			## Perform the checking
			while(@type_constraints) {
				my $type_constraint = shift @type_constraints;
				if(@values) {
					my $value = shift @values;
					unless($type_constraint->check($value)) {
						return;
					}				
				} else {
					return;
				}
			}
			## Make sure there are no leftovers.
			if(@values) {
				return;
			} elsif(@type_constraints) {
				return;
			}else {
				return 1;
			}
		}
	)
);
	
Moose::Util::TypeConstraints::get_type_constraint_registry->add_type_constraint(
	MooseX::Meta::TypeConstraint::Structured->new(
		name => "MooseX::Types::Structured::Dict",
		parent => find_type_constraint('HashRef'),
		constraint_generator=> sub {
			## Get the constraints and values to check
			my %type_constraints = @{shift @_};            
			my %values = %{shift @_};
			## Perform the checking
			while(%type_constraints) {
				my($key, $type_constraint) = each %type_constraints;
				delete $type_constraints{$key};
				if(exists $values{$key}) {
					my $value = $values{$key};
					delete $values{$key};
					unless($type_constraint->check($value)) {
						return;
						#if ($type_constraint->has_coercion) {    
						#	my $temp = $type_constraint->coerce($value);
						#	use Data::Dump qw/dump/; warn dump $value, $temp; 
						#	unless($type_constraint->check($temp)) {
						#		return;
						#	}
						#} else {
						#	return;
						#}
					}
				} else {
					return;
				}
			}
			## Make sure there are no leftovers.
			if(%values) {
				return;
			} elsif(%type_constraints) {
				return;
			}else {
				return 1;
			}
		},
	)
);

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<MooseX::TypeLibrary>, L<Moose::Meta::TypeConstraint>,
L<MooseX::Meta::TypeConstraint::Structured>

=head1 TODO

Need to clarify deep coercions, need to clarify subtypes of subtypes.

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
	
1;
