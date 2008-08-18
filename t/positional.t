BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>6;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Positional;

    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured;
      
    sub Tuple {
        my $args = shift @_;
        return MooseX::Meta::TypeConstraint::Structured->new(
            name => 'Tuple',
            parent => find_type_constraint('ArrayRef'),
            package_defined_in => __PACKAGE__,
            signature => [map {find_type_constraint($_)} @$args],
        );
    }
     
    has 'tuple' => (is=>'rw', isa=>Tuple['Int', 'Str']);
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured::Positional->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured::Positional'
 => 'Created correct object type.';

lives_ok sub {
    $record->tuple([1,'hello']);
} => 'Set tuple attribute without error';

is $record->tuple->[0], 1
 => 'correct set the tuple attribute index 0';

is $record->tuple->[1], 'hello'
 => 'correct set the tuple attribute index 1';

throws_ok sub {
    $record->tuple(['asdasd',2]);      
}, qr/Validation failed for 'Int'/
 => 'Got Expected Error for violating constraints';

