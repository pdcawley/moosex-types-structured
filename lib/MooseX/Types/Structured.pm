package MooseX::Types::Structured;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Meta::TypeConstraint::Structured::Positional;
use MooseX::Meta::TypeConstraint::Structured::Named;
#use MooseX::Types::Moose qw();
#use MooseX::Types -declare => [qw( Dict Tuple Optional )];
  use Sub::Exporter
    -setup => { exports => [ qw(Dict Tuple) ] };
	
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
	

=head1 TYPES

This class defines the following types and subtypes.

=cut

sub Tuple {
	my ($args, $optional) = @_;
	my @args = @$args;
	my @optional = ref $optional eq 'ARRAY' ? @$optional : ();

	return MooseX::Meta::TypeConstraint::Structured::Positional->new(
		name => 'Tuple',
		parent => find_type_constraint('ArrayRef'),
		package_defined_in => __PACKAGE__,
		signature => [map {
			_normalize_type_constraint($_);
		} @args],
		optional_signature => [map {
			_normalize_type_constraint($_);
		} @optional],
	);
}

sub Dict {
	my ($args, $optional) = @_;
	my %args = @$args;
	my %optional = ref $optional eq 'ARRAY' ? @$optional : ();
	
	return MooseX::Meta::TypeConstraint::Structured::Named->new(
		name => 'Dict',
		parent => find_type_constraint('HashRef'),
		package_defined_in => __PACKAGE__,
		signature => {map {
			$_ => _normalize_type_constraint($args{$_});
		} keys %args},
		optional_signature => {map {
			$_ => _normalize_type_constraint($optional{$_});
		} keys %optional},
	);
}

sub _normalize_type_constraint {
	my $tc = shift @_;
	if(defined $tc && blessed $tc && $tc->isa('Moose::Meta::TypeConstraint')) {
		return $tc;
	} elsif($tc) {
		return Moose::Util::TypeConstraints::find_or_parse_type_constraint($tc);
	}
}

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<MooseX::TypeLibrary>, L<Moose::Meta::TypeConstraint>

=head1 BUGS

No known or reported bugs.

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;