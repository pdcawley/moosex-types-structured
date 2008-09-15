BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>10;
	use Test::Exception;
	
	use_ok 'Moose::Util::TypeConstraints';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Generator';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Positional';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Named';
}

my $tuple = MooseX::Meta::TypeConstraint::Structured::Generator->new(
		name => 'Tuple',
		structured_type	=> 'MooseX::Meta::TypeConstraint::Structured::Positional',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('ArrayRef'),
	);

Moose::Util::TypeConstraints::register_type_constraint($tuple);

## Make sure the new type constraints have been registered

ok Moose::Util::TypeConstraints::find_type_constraint('Tuple')
 => 'Found the Tuple Type';

{
	package Test::MooseX::Types::Structured::BasicAttributes;
	
	use Moose;
	use Moose::Util::TypeConstraints;
	
	has 'tuple' => (is=>'rw', isa=>'Tuple[Int,Str,Int]');
}


ok my $positioned_obj = Test::MooseX::Types::Structured::BasicAttributes->new,
 => 'Got a good object';

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




#ok Moose::Util::TypeConstraints::_detect_parameterized_type_constraint('HashRef[key1 => Int, key2=>Int, key3=>ArrayRef[Int]]')
# => 'detected correctly';
 
#is_deeply 
#	[Moose::Util::TypeConstraints::_parse_parameterized_type_constraint('HashRef[key1 => Int, key2=>Int, key3=>ArrayRef[Int]]')],
#	["HashRef", "key1", "Int", "key2", "Int", "key3", "ArrayRef[Int]"]
# => 'Correctly parsed HashRef[key1 => Int, key2=>Int, key3=>ArrayRef[Int]]';