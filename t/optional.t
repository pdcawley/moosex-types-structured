BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>16;
	use Test::Exception;
	use Data::Dump qw/dump/;
	
	use_ok 'Moose::Util::TypeConstraints';
}

Moose::Util::TypeConstraints::register_type_constraint(
	Moose::Meta::TypeConstraint::Parameterizable->new(
		name  => 'Optional',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('Item'),
		constraint => sub { 1 },
		constraint_generator => sub {
			my $type_parameter = shift;
			my $check = $type_parameter->_compiled_type_constraint;
			return sub {
				use Data::Dump qw/dump/;
				warn dump @_;
				return 1 if not(defined($_)) || $check->($_);
				return;
			}
		}
	)
);

ok Moose::Util::TypeConstraints::find_type_constraint('Optional')
 => 'Found the Optional Type';

{
	package Test::MooseX::Types::Optional;
	use Moose;
	
	has 'Maybe_Int' => (is=>'rw', isa=>'Maybe[Int]');
	has 'Maybe_ArrayRef' => (is=>'rw', isa=>'Maybe[ArrayRef]');	
	has 'Maybe_HashRef' => (is=>'rw', isa=>'Maybe[HashRef]');	
	has 'Maybe_ArrayRefInt' => (is=>'rw', isa=>'Maybe[ArrayRef[Int]]');	
	has 'Maybe_HashRefInt' => (is=>'rw', isa=>'Maybe[HashRef[Int]]');	
}

ok my $obj = Test::MooseX::Types::Optional->new
 => 'Create good test object';

##  Maybe[Int]

ok my $Maybe_Int  = Moose::Util::TypeConstraints::find_or_parse_type_constraint('Maybe[Int]')
 => 'made TC Maybe[Int]';
 
ok $Maybe_Int->check(1)
 => 'passed (1)';
 
	ok $obj->Maybe_Int(1)
	 => 'assigned (1)';
 
ok $Maybe_Int->check()
 => 'passed ()';

	ok $obj->Maybe_Int()
	 => 'assigned ()';

ok $Maybe_Int->check(0)
 => 'passed (0)';

	ok defined $obj->Maybe_Int(0)
	 => 'assigned (0)';
 
ok $Maybe_Int->check(undef)
 => 'passed (undef)';
 
	ok sub {$obj->Maybe_Int(undef); 1}->()
	 => 'assigned (undef)';
 
ok !$Maybe_Int->check("")
 => 'failed ("")';
 
	throws_ok sub { $obj->Maybe_Int("") }, 
	 qr/Attribute \(Maybe_Int\) does not pass the type constraint/
	 => 'failed assigned ("")';

ok !$Maybe_Int->check("a")
 => 'failed ("a")';

	throws_ok sub { $obj->Maybe_Int("a") }, 
	 qr/Attribute \(Maybe_Int\) does not pass the type constraint/
	 => 'failed assigned ("a")';

__END__


ok $obj->Maybe_Int(undef)
 => 'passed 1';
 
ok $obj->Maybe_Int();
 
ok $obj->Maybe_Int('')
 => 'passed 1';

ok $obj->Maybe_Int('a')
 => 'passed 1';




ok $obj->tuple([1,'hello',3])
 => "[1,'hello',3] properly suceeds";

throws_ok sub {
	$obj->tuple([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$obj->tuple(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$obj->tuple(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";


## Test tuple_with_parameterized (Tuple[Int,Str,Int,ArrayRef[Int]])

ok $obj->tuple_with_parameterized([1,'hello',3,[1,2,3]])
 => "[1,'hello',3,[1,2,3]] properly suceeds";

throws_ok sub {
	$obj->tuple_with_parameterized([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$obj->tuple_with_parameterized(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$obj->tuple_with_parameterized(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";

throws_ok sub {
	$obj->tuple_with_parameterized([1,'hello',3,[1,2,'world']]);
}, qr/Validation failed for 'ArrayRef\[Int\]'/ => "[1,'hello',3,[1,2,'world']] properly fails";


## Test tuple_with_optional (Tuple[Int,Str,Int,Optional[Int,Int]])

ok $obj->tuple_with_optional([1,'hello',3])
 => "[1,'hello',3] properly suceeds";

ok $obj->tuple_with_optional([1,'hello',3,1])
 => "[1,'hello',3,1] properly suceeds";

ok $obj->tuple_with_optional([1,'hello',3,4])
 => "[1,'hello',3,4] properly suceeds";

ok $obj->tuple_with_optional([1,'hello',3,4,5])
 => "[1,'hello',3,4,5] properly suceeds";

throws_ok sub {
	$obj->tuple_with_optional([1,'hello',3,4,5,6]);
}, qr/Too Many arguments for the available type constraints/ => "[1,'hello',3,4,5,6] properly fails";

throws_ok sub {
	$obj->tuple_with_optional([1,2,'world']);
}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

throws_ok sub {
	$obj->tuple_with_optional(['hello1',2,3]);
}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

throws_ok sub {
	$obj->tuple_with_optional(['hello2',2,'world']);
}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";

## tuple_with_union Tuple[Int,Str,Int|Object,Optional[Int|Object,Int]]

SKIP: {

	skip "Unions not supported for string parsed type constraints" => 8;

	ok $obj->tuple_with_union([1,'hello',3])
	 => "[1,'hello',3] properly suceeds";

	ok $obj->tuple_with_union([1,'hello',3,1])
	 => "[1,'hello',3,1] properly suceeds";

	ok $obj->tuple_with_union([1,'hello',3,4])
	 => "[1,'hello',3,4] properly suceeds";

	ok $obj->tuple_with_union([1,'hello',3,4,5])
	 => "[1,'hello',3,4,5] properly suceeds";

	throws_ok sub {
		$obj->tuple_with_union([1,'hello',3,4,5,6]);
	}, qr/Too Many arguments for the available type constraints/ => "[1,'hello',3,4,5,6] properly fails";

	throws_ok sub {
		$obj->tuple_with_union([1,2,'world']);
	}, qr/Validation failed for 'Int' failed with value world/ => "[1,2,'world'] properly fails";

	throws_ok sub {
		$obj->tuple_with_union(['hello1',2,3]);
	}, qr/Validation failed for 'Int' failed with value hello1/ => "['hello',2,3] properly fails";

	throws_ok sub {
		$obj->tuple_with_union(['hello2',2,'world']);
	}, qr/Validation failed for 'Int' failed with value hello2/ => "['hello',2,'world'] properly fails";
}

