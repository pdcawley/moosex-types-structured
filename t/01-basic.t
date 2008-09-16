BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>36;
	use Test::Exception;
	
	use_ok 'Moose::Util::TypeConstraints';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Generator';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Positional';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Optional';	
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Named';
}

my $optional = MooseX::Meta::TypeConstraint::Structured::Generator->new(
		name => 'Optional',
		structured_type	=> 'MooseX::Meta::TypeConstraint::Structured::Optional',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('ArrayRef'),
	);

my $tuple = MooseX::Meta::TypeConstraint::Structured::Generator->new(
		name => 'Tuple',
		structured_type	=> 'MooseX::Meta::TypeConstraint::Structured::Positional',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('ArrayRef'),
	);
	
my $dict = MooseX::Meta::TypeConstraint::Structured::Generator->new(
		name => 'Dict',
		structured_type	=> 'MooseX::Meta::TypeConstraint::Structured::Named',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('HashRef'),
	);

Moose::Util::TypeConstraints::register_type_constraint($optional);
Moose::Util::TypeConstraints::register_type_constraint($tuple);
Moose::Util::TypeConstraints::register_type_constraint($dict);

## Make sure the new type constraints have been registered

ok Moose::Util::TypeConstraints::find_type_constraint('Tuple')
 => 'Found the Tuple Type';
 
ok Moose::Util::TypeConstraints::find_type_constraint('Dict')
 => 'Found the Tuple Type';
 
ok Moose::Util::TypeConstraints::find_type_constraint('Optional')
 => 'Found the Tuple Type';

{
	package Test::MooseX::Types::Structured::BasicAttributes;
	
	use Moose;
	use Moose::Util::TypeConstraints;
	
	has 'tuple' => (is=>'rw', isa=>'Tuple[Int,Str,Int]');
	has 'tuple_with_parameterized' => (is=>'rw', isa=>'Tuple[Int,Str,Int,ArrayRef[Int]]');
	has 'tuple_with_optional' => (is=>'rw', isa=>'Tuple[Int,Str,Int,Optional[Int,Int]]');
	has 'tuple_with_union' => (is=>'rw', isa=>'Tuple[Int,Str,Int|Object,Optional[Int|Object,Int]]');
	
	has 'dict' => (is=>'rw', isa=>'Dict[name=>Str, Age=>Int]');
	has 'dict_with_parameterized' => (is=>'rw', isa=>'Dict[name=>Str, Age=>Int, telephone=>ArrayRef[Int]]');
	has 'dict_with_optional' => (is=>'rw', isa=>'Dict[name=>Str, Age=>Int, Optional[opt1=>Str,Opt2=>Object]]');

}

#use Data::Dump qw/dump/;
#warn dump Moose::Util::TypeConstraints::list_all_type_constraints;

ok my $positioned_obj = Test::MooseX::Types::Structured::BasicAttributes->new,
 => 'Got a good object';

ok Moose::Util::TypeConstraints::find_type_constraint('Tuple[Int,Str,Int]')
 => 'Found expected type constraint';

ok Moose::Util::TypeConstraints::find_type_constraint('Tuple[Int,Str,Int,Optional[Int,Int]]')
 => 'Found expected type constraint';
 
## Test tuple (Tuple[Int,Str,Int])

ok $positioned_obj->tuple([1,'hello',3])
 => "[1,'hello',3] properly suceeds";

throws_ok sub {
	$positioned_obj->tuple([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$positioned_obj->tuple(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$positioned_obj->tuple(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";


## Test tuple_with_parameterized (Tuple[Int,Str,Int,ArrayRef[Int]])

ok $positioned_obj->tuple_with_parameterized([1,'hello',3,[1,2,3]])
 => "[1,'hello',3,[1,2,3]] properly suceeds";

throws_ok sub {
	$positioned_obj->tuple_with_parameterized([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_parameterized(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_parameterized(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_parameterized([1,'hello',3,[1,2,'world']]);
}, qr/Validation failed for 'ArrayRef\[Int\]'/ => "[1,'hello',3,[1,2,'world']] properly fails";


## Test tuple_with_optional (Tuple[Int,Str,Int,Optional[Int,Int]])

ok $positioned_obj->tuple_with_optional([1,'hello',3])
 => "[1,'hello',3] properly suceeds";

ok $positioned_obj->tuple_with_optional([1,'hello',3,1])
 => "[1,'hello',3,1] properly suceeds";

ok $positioned_obj->tuple_with_optional([1,'hello',3,4])
 => "[1,'hello',3,4] properly suceeds";

ok $positioned_obj->tuple_with_optional([1,'hello',3,4,5])
 => "[1,'hello',3,4,5] properly suceeds";

throws_ok sub {
	$positioned_obj->tuple_with_optional([1,'hello',3,4,5,6]);
}, qr/Too Many arguments for the available type constraints/ => "[1,'hello',3,4,5,6] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_optional([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_optional(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$positioned_obj->tuple_with_optional(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";

## tuple_with_union Tuple[Int,Str,Int|Object,Optional[Int|Object,Int]]

SKIP: {

	skip "Unions not supported for string parsed type constraints" => 8;

	ok $positioned_obj->tuple_with_union([1,'hello',3])
	 => "[1,'hello',3] properly suceeds";

	ok $positioned_obj->tuple_with_union([1,'hello',3,1])
	 => "[1,'hello',3,1] properly suceeds";

	ok $positioned_obj->tuple_with_union([1,'hello',3,4])
	 => "[1,'hello',3,4] properly suceeds";

	ok $positioned_obj->tuple_with_union([1,'hello',3,4,5])
	 => "[1,'hello',3,4,5] properly suceeds";

	throws_ok sub {
		$positioned_obj->tuple_with_union([1,'hello',3,4,5,6]);
	}, qr/Too Many arguments for the available type constraints/ => "[1,'hello',3,4,5,6] properly fails";

	throws_ok sub {
		$positioned_obj->tuple_with_union([1,2,'world']);
	}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

	throws_ok sub {
		$positioned_obj->tuple_with_union(['hello1',2,3]);
	}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

	throws_ok sub {
		$positioned_obj->tuple_with_union(['hello2',2,'world']);
	}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";
}

