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
		my $name = _->{first_name} .' '. $_->{last_name};
		my $age = $_->{dob} - DateTime->now;
		MyApp::MyStruct->new(
			name=>$name,
			age=>$age->years );
	 };
	

=head1 METHODS

This class defines the following methods

=head2 type_storage

Override the type_storage method so that we can inline the types.  We do this
because if we try to say "type Dict, $dict" or similar, I found that
L<Moose::Util::TypeConstraints> automatically wraps a L<Moose::Meta::TypeConstraint>
object around my Structured type, which then throws an error since the base
Type Constraint object doesn't have a parameterize method.

In the future, might make all these play more nicely with Parameterized types,
and then this nasty override can go away.

=cut

sub type_storage {
	return {
		Tuple => MooseX::Meta::TypeConstraint::Structured->new(
			name => 'Tuple',
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
		),
		Dict => MooseX::Meta::TypeConstraint::Structured->new(
			name => 'Dict',
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
		),
	};
}

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<MooseX::TypeLibrary>, L<Moose::Meta::TypeConstraint>,
L<MooseX::Meta::TypeConstraint::Structured>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;