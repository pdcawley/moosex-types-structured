BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>32;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Tuple;

    use Moose;
    use MooseX::Types::Structured qw(Tuple);
	use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef Maybe);
	use MooseX::Types -declare => [qw(MyString MoreThanFive FiveByFive MyArrayRefMoreThanTwoInt)];
	
    subtype MyString,
     as Str,
     where { $_=~m/abc/};
     
    subtype MoreThanFive,
     as Int,
     where { $_ > 5};
     
    subtype MyArrayRefMoreThanTwoInt,
     as ArrayRef[MoreThanFive],
     where { scalar @$_ > 2 };
     
    subtype FiveByFive,
     as Tuple[MoreThanFive, MyArrayRefMoreThanTwoInt];
     
    #use Data::Dump qw/dump/; warn dump Tuple;

    has 'tuple' => (is=>'rw', isa=>Tuple[Int, Str, MyString]);
	has 'tuple_with_param' => (is=>'rw', isa=>Tuple[Int, Str, ArrayRef[Int]]);
	has 'tuple_with_maybe' => (is=>'rw', isa=>Tuple[Int, Str, Maybe[Int], Object]);
	has 'tuple_with_maybe2' => (is=>'rw', isa=>Tuple[Int, Str, Maybe[Int]]);	
	has 'tuple_with_union' => (is=>'rw', isa=>Tuple[Int,Str,Int|Object,Int]);
	has 'tuple2' => (is=>'rw', isa=>Tuple[Int,Str,Int]);
	has 'tuple_with_parameterized' => (is=>'rw', isa=>Tuple[Int,Str,Int,ArrayRef[Int]]);
    has 'FiveByFiveAttr' => (is=>'rw', isa=>FiveByFive);
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured::Tuple->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured::Tuple'
 => 'Created correct object type.';
 
## Test Tuple type constraint

lives_ok sub {
    $record->tuple([1,'hello', 'test.abc.test']);
} => 'Set tuple attribute without error';

is $record->tuple->[0], 1
 => 'correct set the tuple attribute index 0';

is $record->tuple->[1], 'hello'
 => 'correct set the tuple attribute index 1';

is $record->tuple->[2], 'test.abc.test'
 => 'correct set the tuple attribute index 2';

throws_ok sub {
    $record->tuple([1,'hello', 'test.xxx.test']);    
}, qr/Attribute \(tuple\) does not pass the type constraint/
 => 'Properly failed for bad value in custom type constraint';
 
throws_ok sub {
    $record->tuple(['asdasd',2, 'test.abc.test']);      
}, qr/Attribute \(tuple\) does not pass the type constraint/
 => 'Got Expected Error for violating constraints';

## Test tuple_with_maybe

lives_ok sub {
    $record->tuple_with_maybe([1,'hello', 1, $record]);
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->tuple_with_maybe([1,'hello', 'a', $record]);
}, qr/Attribute \(tuple_with_maybe\) does not pass the type constraint/
 => 'Properly failed for bad value parameterized constraint';

lives_ok sub {
    $record->tuple_with_maybe([1,'hello',undef, $record]);
} => 'Set tuple attribute without error skipping optional parameter';

## Test tuple_with_maybe2

lives_ok sub {
    $record->tuple_with_maybe2([1,'hello', 1]);
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->tuple_with_maybe2([1,'hello', 'a']);
}, qr/Attribute \(tuple_with_maybe2\) does not pass the type constraint/
 => 'Properly failed for bad value parameterized constraint';

lives_ok sub {
    $record->tuple_with_maybe2([1,'hello',undef]);
} => 'Set tuple attribute without error skipping optional parameter';

throws_ok sub {
    $record->tuple_with_maybe2([1,'hello']);
}, qr/Attribute \(tuple_with_maybe2\) does not pass the type constraint/
 => 'Properly fails for missing maybe (needs to be at least undef)';

## Test Tuple with parameterized type

lives_ok sub {
    $record->tuple_with_param([1,'hello', [1,2,3]]);
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->tuple_with_param([1,'hello', [qw/a b c/]]);
}, qr/Attribute \(tuple_with_param\) does not pass the type constraint/
 => 'Properly failed for bad value parameterized constraint';

## Test tuple2 (Tuple[Int,Str,Int])

ok $record->tuple2([1,'hello',3])
 => "[1,'hello',3] properly suceeds";

throws_ok sub {
	$record->tuple2([1,2,'world']);
}, qr/Attribute \(tuple2\) does not pass the type constraint/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$record->tuple2(['hello1',2,3]);
}, qr/Attribute \(tuple2\) does not pass the type constraint/ => "['hello',2,3] properly fails";

throws_ok sub {
	$record->tuple2(['hello2',2,'world']);
}, qr/Attribute \(tuple2\) does not pass the type constraint/ => "['hello',2,'world'] properly fails";


## Test tuple_with_parameterized (Tuple[Int,Str,Int,ArrayRef[Int]])

ok $record->tuple_with_parameterized([1,'hello',3,[1,2,3]])
 => "[1,'hello',3,[1,2,3]] properly suceeds";

throws_ok sub {
	$record->tuple_with_parameterized([1,2,'world']);
}, qr/Attribute \(tuple_with_parameterized\) does not pass the type constraint/
 => "[1,2,'world'] properly fails";

throws_ok sub {
	$record->tuple_with_parameterized(['hello1',2,3]);
}, qr/Attribute \(tuple_with_parameterized\) does not pass the type constraint/
 => "['hello',2,3] properly fails";

throws_ok sub {
	$record->tuple_with_parameterized(['hello2',2,'world']);
}, qr/Attribute \(tuple_with_parameterized\) does not pass the type constraint/
 => "['hello',2,'world'] properly fails";

throws_ok sub {
	$record->tuple_with_parameterized([1,'hello',3,[1,2,'world']]);
}, qr/Attribute \(tuple_with_parameterized\) does not pass the type constraint/
 => "[1,'hello',3,[1,2,'world']] properly fails";

## Test FiveByFiveAttr

lives_ok sub {
    $record->FiveByFiveAttr([6,[7,8,9]]);
} => 'Set FiveByFiveAttr correctly';

throws_ok sub {
    $record->FiveByFiveAttr([1,'hello', 'test']);    
}, qr/Attribute \(FiveByFiveAttr\) does not pass the type constraint/
 => q{Properly failed for bad value in FiveByFiveAttr [1,'hello', 'test']};

throws_ok sub {
    $record->FiveByFiveAttr([1,[8,9,10]]);    
}, qr/Attribute \(FiveByFiveAttr\) does not pass the type constraint/
 => q{Properly failed for bad value in FiveByFiveAttr [1,[8,9,10]]};
 
throws_ok sub {
    $record->FiveByFiveAttr([10,[11,12,0]]);    
}, qr/Attribute \(FiveByFiveAttr\) does not pass the type constraint/
 => q{Properly failed for bad value in FiveByFiveAttr [10,[11,12,0]]};
 
throws_ok sub {
    $record->FiveByFiveAttr([1,[1,1,0]]);    
}, qr/Attribute \(FiveByFiveAttr\) does not pass the type constraint/
 => q{Properly failed for bad value in FiveByFiveAttr [1,[1,1,0]]};

throws_ok sub {
    $record->FiveByFiveAttr([10,[11,12]]);    
}, qr/Attribute \(FiveByFiveAttr\) does not pass the type constraint/
 => q{Properly failed for bad value in FiveByFiveAttr [10,[11,12]};
 
