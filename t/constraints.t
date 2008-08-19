BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>8;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Positional;

    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured;
    
    subtype 'MyString',
     as 'Str',
     where { $_=~m/abc/};
      
    sub Tuple {
        my $args = shift @_;
        return MooseX::Meta::TypeConstraint::Structured->new(
            name => 'Tuple',
            parent => find_type_constraint('ArrayRef'),
            package_defined_in => __PACKAGE__,
            signature => [map {find_type_constraint($_)} @$args],
        );
    }

    has 'tuple' => (is=>'rw', isa=>Tuple['Int', 'Str', 'MyString']);
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured::Positional->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured::Positional'
 => 'Created correct object type.';

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

