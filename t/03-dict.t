BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>17;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Dict;

    use Moose;
    use MooseX::Types::Structured qw(Dict Tuple);
	use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef Maybe);
	use MooseX::Types -declare => [qw(MyString)];
	
    subtype MyString,
     as Str,
     where { $_=~m/abc/};
	 
    has 'dict' => (is=>'rw', isa=>Dict[name=>Str, age=>Int]);
    has 'dict_with_maybe' => (is=>'rw', isa=>Dict[name=>Str, age=>Maybe[Int]]);	
    has 'dict_with_tuple_with_union' => (is=>'rw', isa=>Dict[key1=>Str|Object, key2=>Tuple[Int,Str|Object]] );
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured::Dict->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured::Dict'
 => 'Created correct object type.';
 
# Test dict Dict[name=>Str, age=>Int]
 
lives_ok sub {
    $record->dict({name=>'frith', age=>23});
} => 'Set dict attribute without error';

is $record->dict->{name}, 'frith'
 => 'correct set the dict attribute name';

is $record->dict->{age}, 23
 => 'correct set the dict attribute age';
 
throws_ok sub {
    $record->dict({name=>[1,2,3], age=>'sdfsdfsd'});      
}, qr/Attribute \(dict\) does not pass the type constraint/
 => 'Got Expected Error for bad value in dict';
 
## Test dict_with_maybe

lives_ok sub {
    $record->dict_with_maybe({name=>'frith', age=>23});
} => 'Set dict attribute without error';

is $record->dict_with_maybe->{name}, 'frith'
 => 'correct set the dict attribute name';

is $record->dict_with_maybe->{age}, 23
 => 'correct set the dict attribute age';
 
throws_ok sub {
    $record->dict_with_maybe({name=>[1,2,3], age=>'sdfsdfsd'});      
}, qr/Attribute \(dict_with_maybe\) does not pass the type constraint/
 => 'Got Expected Error for bad value in dict';

throws_ok sub {
    $record->dict_with_maybe({age=>30});      
}, qr/Attribute \(dict_with_maybe\) does not pass the type constraint/
 => 'Got Expected Error for missing named parameter';

lives_ok sub {
    $record->dict_with_maybe({name=>'usal', age=>undef});
} => 'Set dict attribute without error, skipping maybe';

## Test dict_with_tuple_with_union: Dict[key1=>'Str|Object', key2=>Tuple['Int','Str|Object']]

lives_ok sub {
    $record->dict_with_tuple_with_union({key1=>'Hello', key2=>[1,'World']});
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->dict_with_tuple_with_union({key1=>'Hello', key2=>['World',2]});
}, qr/Attribute \(dict_with_tuple_with_union\) does not pass the type constraint/
 => 'Threw error on bad constraint';
 
lives_ok sub {
    $record->dict_with_tuple_with_union({key1=>$record, key2=>[1,'World']});
} => 'Set tuple attribute without error';

lives_ok sub {
    $record->dict_with_tuple_with_union({key1=>'Hello', key2=>[1,$record]});
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->dict_with_tuple_with_union({key1=>1, key2=>['World',2]});
}, qr/Attribute \(dict_with_tuple_with_union\) does not pass the type constraint/
 => 'Threw error on bad constraint';
