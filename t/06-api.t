BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>12;
	use Test::Exception;
}

{
	## Tests for the Moose::Meta::TypeConstraints API stuff (equals, etc)
    package Test::MooseX::Meta::TypeConstraint::Structured::API;

    use Moose;
    use MooseX::Types::Structured qw(Dict Tuple);
	use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef);
	use MooseX::Types -declare => [qw(
        MyDict1 MyDict2 MyDict3 subMyDict3
		MyTuple1 MyTuple2 MyTuple3 subMyTuple3
    )];
    
	## Create some sample Dicts
	
    my $MyDict1 = subtype MyDict1,
     as Dict[name=>Str, age=>Int];
	
    my $MyDict2 = subtype MyDict2,
     as Dict[name=>Str, age=>Int];
	 
    my $MyDict3 = subtype MyDict3,
     as Dict[key=>Int, anotherkey=>Str];
	 
	my $subMyDict3 = subtype subMyDict3,
	 as MyDict3;

	## Create some sample Tuples
	
	my $MyTuple1 = subtype MyTuple1,
	 as Tuple[Int,Int,Str];

	my $MyTuple2 = subtype MyTuple2,
	 as Tuple[Int,Int,Str];
	 
	my $MyTuple3 = subtype MyTuple3,
	 as Tuple[Object, HashRef];

	my $subMyTuple3 = subtype subMyTuple3,
	 as MyTuple3;
}

## Test equals

ok $MyDict1->equals($MyDict2), '$MyDict1 == $MyDict2';
ok $MyDict2->equals($MyDict1), '$MyDict2 == $MyDict1';
ok ! $MyDict1->equals($MyDict3), '$MyDict1 == $MyDict3';
ok ! $MyDict2->equals($MyDict3), '$MyDict2 == $MyDict3';
ok ! $MyDict3->equals($MyDict2), '$MyDict3 == $MyDict2';
ok ! $MyDict3->equals($MyDict1), '$MyDict3 == $MyDict1';

ok $MyTuple1->equals($MyTuple2), '$MyTuple1 == $MyTuple2';
ok $MyTuple2->equals($MyTuple1), '$MyTuple2 == $MyTuple1';
ok ! $MyTuple1->equals($MyTuple3), '$MyTuple1 == $MyTuple3';
ok ! $MyTuple2->equals($MyTuple3), '$MyTuple2 == $MyTuple3';
ok ! $MyTuple3->equals($MyTuple2), '$MyTuple3 == $MyTuple2';
ok ! $MyTuple3->equals($MyTuple1), '$MyTuple3 == $MyTuple1';

## Test is_a_type_of

## is_subtype_of


