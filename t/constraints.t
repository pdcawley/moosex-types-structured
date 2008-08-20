BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>25;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured;

    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Meta::TypeConstraint::Structured::Named;
    use MooseX::Meta::TypeConstraint::Structured::Positional;

    subtype 'MyString',
     as 'Str',
     where { $_=~m/abc/};

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
        );
    }

    sub Dict {
        my ($args, $optional) = @_;
        my %args = @$args;
        my %optional = ref $optional eq 'HASH' ? @$optional : ();
        
        return MooseX::Meta::TypeConstraint::Structured::Named->new(
            name => 'Dict',
            parent => find_type_constraint('HashRef'),
            package_defined_in => __PACKAGE__,
            signature => {map {
				$_ => _normalize_type_constraint($args{$_});
			} keys %args},
        );
    }

	sub _normalize_type_constraint {
		my $tc = shift @_;
		if($tc && blessed $tc && $tc->isa('Moose::Meta::TypeConstraint')) {
			return $tc;
		} elsif($tc) {
			return Moose::Util::TypeConstraints::find_or_parse_type_constraint($tc);
		}
	}

    has 'tuple' => (is=>'rw', isa=>Tuple['Int', 'Str', 'MyString']);
    has 'dict' => (is=>'rw', isa=>Dict[name=>'Str', age=>'Int']);
    has 'dict_with_maybe' => (is=>'rw', isa=>Dict[name=>'Str', age=>'Maybe[Int]']);	
	has 'tuple_with_param' => (is=>'rw', isa=>Tuple['Int', 'Str', 'ArrayRef[Int]']);
	has 'tuple_with_maybe' => (is=>'rw', isa=>Tuple['Int', 'Str', 'Maybe[Int]']);
	has 'dict_with_tuple' => (is=>'rw', isa=>Dict[key1=>'Str', key2=>Tuple['Int','Str']]);
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

## Test tuple_with_maybe

lives_ok sub {
    $record->tuple_with_maybe([1,'hello', 1]);
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->tuple_with_maybe([1,'hello', 'a']);
}, qr/Validation failed for 'Maybe\[Int\]'/
 => 'Properly failed for bad value parameterized constraint';

lives_ok sub {
    $record->tuple_with_maybe([1,'hello']);
} => 'Set tuple attribute without error skipping optional parameter';

## Test Tuple with parameterized type

lives_ok sub {
    $record->tuple_with_param([1,'hello', [1,2,3]]);
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->tuple_with_param([1,'hello', [qw/a b c/]]);
}, qr/Validation failed for 'ArrayRef\[Int\]'/
 => 'Properly failed for bad value parameterized constraint';

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
}, qr/Validation failed for 'Str'/
 => 'Got Expected Error for bad value in dict';

throws_ok sub {
    $record->dict_with_maybe({age=>30});      
}, qr/Validation failed for 'Str'/
 => 'Got Expected Error for missing named parameter';

lives_ok sub {
    $record->dict_with_maybe({name=>'usal'});
} => 'Set dict attribute without error, skipping optional';

## Test dict_with_tuple

lives_ok sub {
    $record->dict_with_tuple({key1=>'Hello', key2=>[1,'World']});
} => 'Set tuple attribute without error';

throws_ok sub {
    $record->dict_with_tuple({key1=>'Hello', key2=>['World',2]});
}, qr/Validation failed for 'Int'/
 => 'Threw error on bad constraint';



