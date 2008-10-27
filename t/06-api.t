BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>44;
	use Test::Exception;
}

use MooseX::Types::Structured qw(Dict Tuple);
use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef);
use MooseX::Types -declare => [qw(
    MyDict1 MyDict2 MyDict3 subMyDict3 subMyDict1
    MyTuple1 MyTuple2 MyTuple3 subMyTuple3
)];

## Create some sample Dicts

subtype MyDict1,
 as Dict[name=>Str, age=>Int];

subtype subMyDict1,
 as MyDict1;

subtype MyDict2,
 as Dict[name=>Str, age=>Int];
 
subtype MyDict3,
 as Dict[key=>Int, anotherkey=>Str];
 
subtype subMyDict3,
 as MyDict3;

## Create some sample Tuples

subtype MyTuple1,
 as Tuple[Int,Int,Str];

subtype MyTuple2,
 as Tuple[Int,Int,Str];
 
subtype MyTuple3,
 as Tuple[Object, HashRef];

subtype subMyTuple3,
 as MyTuple3;

## Test equals

ok ( MyDict1->equals(MyDict2), 'MyDict1 == MyDict2');
ok ( MyDict2->equals(MyDict1), 'MyDict2 == MyDict1');
ok (!MyDict1->equals(MyDict3), 'MyDict1 == MyDict3');
ok (!MyDict2->equals(MyDict3), 'MyDict2 == MyDict3');
ok (!MyDict3->equals(MyDict2), 'MyDict3 == MyDict2');
ok (!MyDict3->equals(MyDict1), 'MyDict3 == MyDict1');

ok ( MyTuple1->equals(MyTuple2), 'MyTuple1 == MyTuple2');
ok ( MyTuple2->equals(MyTuple1), 'MyTuple2 == MyTuple1');
ok (!MyTuple1->equals(MyTuple3), 'MyTuple1 == MyTuple3');
ok (!MyTuple2->equals(MyTuple3), 'MyTuple2 == MyTuple3');
ok (!MyTuple3->equals(MyTuple2), 'MyTuple3 == MyTuple2');
ok (!MyTuple3->equals(MyTuple1), 'MyTuple3 == MyTuple1');

## Test is_a_type_of

ok ( MyDict1->is_a_type_of(Dict), 'MyDict1 is_a_type_of Dict');
ok (!MyDict1->is_a_type_of(Tuple), 'MyDict1 NOT is_a_type_of Tuple');
ok ( MyDict1->is_a_type_of(MyDict2), 'MyDict1 is_a_type_of MyDict2');
ok ( MyDict2->is_a_type_of(MyDict1), 'MyDict2 is_a_type_of MyDict1');
ok (!MyDict1->is_a_type_of(MyDict3), 'MyDict1 NOT is_a_type_of MyDict3');
ok (!MyDict2->is_a_type_of(MyDict3), 'MyDict2 NOT is_a_type_of MyDict3');
ok ( subMyDict1->is_a_type_of(Dict), 'subMyDict1 type of Dict');
ok ( subMyDict1->is_a_type_of(MyDict1), 'subMyDict1 type of MyDict1');
ok ( subMyDict1->is_a_type_of(subMyDict1), 'subMyDict1 type of subMyDict1');
ok ( subMyDict1->is_a_type_of(MyDict2), 'subMyDict1 type of MyDict2');

ok ( MyTuple1->is_a_type_of(Tuple), 'MyTuple1 is_a_type_of Tuple');
ok (!MyTuple1->is_a_type_of(Dict), 'MyTuple1 NOT is_a_type_of Dict');
ok ( MyTuple1->is_a_type_of(MyTuple2), 'MyTuple1 is_a_type_of MyTuple2');
ok ( MyTuple2->is_a_type_of(MyTuple1), 'MyTuple2 is_a_type_of MyTuple1');
ok (!MyTuple1->is_a_type_of(MyTuple3), 'MyTuple1 NOT is_a_type_of MyTuple3');
ok (!MyTuple2->is_a_type_of(MyTuple3), 'MyTuple2 NOT is_a_type_of MyTuple3');

## is_subtype_of

ok ( MyDict1->is_subtype_of(Dict), 'MyDict1 is_subtype_of Dict');
ok (!MyDict1->is_subtype_of(Tuple), 'MyDict1 NOT is_subtype_of Tuple');
ok (!MyDict1->is_subtype_of(MyDict2), 'MyDict1 is_subtype_of MyDict2');
ok (!MyDict2->is_subtype_of(MyDict1), 'MyDict2 is_subtype_of MyDict1');
ok (!MyDict1->is_subtype_of(MyDict3), 'MyDict1 NOT is_subtype_of MyDict3');
ok (!MyDict2->is_subtype_of(MyDict3), 'MyDict2 NOT is_subtype_of MyDict3');
ok ( subMyDict1->is_subtype_of(Dict), 'subMyDict1 is_subtype_of Dict');
ok ( subMyDict1->is_subtype_of(MyDict1), 'subMyDict1 is_subtype_of MyDict1');
ok (!subMyDict1->is_subtype_of(subMyDict1), 'subMyDict1 is_subtype_of subMyDict1');
ok ( subMyDict1->is_subtype_of(MyDict2), 'subMyDict1 is_subtype_of MyDict2');

ok ( MyTuple1->is_subtype_of(Tuple), 'MyTuple1 is_subtype_of Tuple');
ok (!MyTuple1->is_subtype_of(Dict), 'MyTuple1 NOT is_subtype_of Dict');
ok (!MyTuple1->is_subtype_of(MyTuple2), 'MyTuple1 is_subtype_of MyTuple2');
ok (!MyTuple2->is_subtype_of(MyTuple1), 'MyTuple2 is_subtype_of MyTuple1');
ok (!MyTuple1->is_subtype_of(MyTuple3), 'MyTuple1 NOT is_subtype_of MyTuple3');
ok (!MyTuple2->is_subtype_of(MyTuple3), 'MyTuple2 NOT is_subtype_of MyTuple3');

