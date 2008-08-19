BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>12;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured;

    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured;
    
    subtype 'MyString',
     as 'Str',
     where { $_=~m/abc/};
      
    sub Tuple {
        my @args = @{shift @_};
        return MooseX::Meta::TypeConstraint::Structured->new(
            name => 'Tuple',
            parent => find_type_constraint('ArrayRef'),
            package_defined_in => __PACKAGE__,
            signature => [map {find_type_constraint($_)} @args],
        );
    }
	
    sub Dict {
        my %args = @{shift @_};
        return MooseX::Meta::TypeConstraint::Structured->new(
            name => 'Tuple',
            parent => find_type_constraint('HashRef'),
            package_defined_in => __PACKAGE__,
            signature => {map { $_ => find_type_constraint($args{$_})} keys %args},
        );
    }

    has 'tuple' => (is=>'rw', isa=>Tuple['Int', 'Str', 'MyString']);
    has 'dict' => (is=>'rw', isa=>Dict[name=>'Str', age=>'Int']);
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured'
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
}, qr/Validation failed for 'MyString'/
 => 'Properly failed for bad value in custom type constraint';
 
throws_ok sub {
    $record->tuple(['asdasd',2, 'test.abc.test']);      
}, qr/Validation failed for 'Int'/
 => 'Got Expected Error for violating constraints';

## Test the Dictionary type constraint
 
lives_ok sub {
    $record->dict({name=>'frith', age=>23});
} => 'Set dict attribute without error';

is $record->dict->{name}, 'frith'
 => 'correct set the dict attribute name';

is $record->dict->{age}, 23
 => 'correct set the dict attribute age';
 
throws_ok sub {
    $record->dict({name=>[1,2,3], age=>'sdfsdfsd'});      
}, qr/Validation failed for 'Str'/
 => 'Got Expected Error for bad value in dict';
