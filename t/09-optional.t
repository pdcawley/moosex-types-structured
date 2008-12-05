use strict;
use warnings;

use Test::More tests=>26;
use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw(Optional);

## Setup Stuff
ok my $Optional = Moose::Util::TypeConstraints::find_or_parse_type_constraint('MooseX::Types::Structured::Optional')
 => 'Got Optional';

isa_ok $Optional
 => 'Moose::Meta::TypeConstraint::Parameterizable';

ok my $int = Moose::Util::TypeConstraints::find_or_parse_type_constraint('Int')
 => 'Got Int';

ok my $arrayref = Moose::Util::TypeConstraints::find_or_parse_type_constraint('ArrayRef[Int]')
 => 'Got ArrayRef[Int]';

BASIC: {
	ok my $Optional_Int = $Optional->parameterize($int), 'Parameterized Int';
	ok my $Optional_ArrayRef = $Optional->parameterize($arrayref), 'Parameterized ArrayRef';
	
	ok $Optional_Int->check() => 'Optional is allowed to not exist';
	
	ok !$Optional_Int->check(undef) => 'Optional is NOT allowed to be undef';
	ok $Optional_Int->check(199) => 'Correctly validates 199';
	ok !$Optional_Int->check("a") => 'Correctly fails "a"';
	
	ok $Optional_ArrayRef->check() => 'Optional is allowed to not exist';
	ok !$Optional_ArrayRef->check(undef) => 'Optional is NOT allowed to be undef';
	ok $Optional_ArrayRef->check([1,2,3]) => 'Correctly validates [1,2,3]';
	ok !$Optional_ArrayRef->check("a") => 'Correctly fails "a"';
	ok !$Optional_ArrayRef->check(["a","b"]) => 'Correctly fails ["a","b"]';	
}

SUBREF: {
	ok my $Optional_Int = Optional->parameterize($int),'Parameterized Int';
	ok my $Optional_ArrayRef = Optional->parameterize($arrayref), 'Parameterized ArrayRef';
	
	ok $Optional_Int->check() => 'Optional is allowed to not exist';
	
	ok !$Optional_Int->check(undef) => 'Optional is NOT allowed to be undef';
	ok $Optional_Int->check(199) => 'Correctly validates 199';
	ok !$Optional_Int->check("a") => 'Correctly fails "a"';
	
	ok $Optional_ArrayRef->check() => 'Optional is allowed to not exist';
	ok !$Optional_ArrayRef->check(undef) => 'Optional is NOT allowed to be undef';
	ok $Optional_ArrayRef->check([1,2,3]) => 'Correctly validates [1,2,3]';
	ok !$Optional_ArrayRef->check("a") => 'Correctly fails "a"';
	ok !$Optional_ArrayRef->check(["a","b"]) => 'Correctly fails ["a","b"]';		
}

## Test via the subref Optional()

