use strict;
use warnings;

use Test::More tests=>15;
use Moose::Util::TypeConstraints;
use Moose::Meta::TypeConstraint::Parameterizable;
use Moose;


ok my $Optional = Moose::Meta::TypeConstraint::Parameterizable->new(
	name => 'Optional',
	package_defined_in => __PACKAGE__,
	parent => find_type_constraint('Item'),
	constraint => sub { 1 },
	constraint_generator => sub {
		my $type_parameter = shift;
		my $check = $type_parameter->_compiled_type_constraint;
		return sub {
			my (@args) = @_;
			if(exists($args[0])) {
				## If it exists, we need to validate it
				$check->($args[0]);
			} else {
				## But it's is okay if the value doesn't exists
				return 1;
			}
		}
	}
);

Moose::Util::TypeConstraints::add_parameterizable_type($Optional);
use Data::Dump qw/dump/;

    foreach my $type (Moose::Util::TypeConstraints::get_all_parameterizable_types()) {
        if (my $constraint = $type->generate_constraint_for($Optional)) {
            warn 'got this FARRRRRR..........................................';           
        }
    }



isa_ok $Optional, 'Moose::Meta::TypeConstraint::Parameterizable';

ok my $int = find_type_constraint('Int') => 'Got Int';
ok my $arrayref = find_type_constraint('ArrayRef[Int]') => 'Got ArrayRef[Int]';

ok my $Optional_Int = $Optional->parameterize($int);
ok my $Optional_ArrayRef = $Optional->parameterize($arrayref);


ok $Optional_Int->check() => 'Optional is allowed to not exist';
ok !$Optional_Int->check(undef) => 'Optional is NOT allowed to be undef';
ok $Optional_Int->check(199) => 'Correctly validates 199';
ok !$Optional_Int->check("a") => 'Correctly fails "a"';

ok $Optional_ArrayRef->check() => 'Optional is allowed to not exist';
ok !$Optional_ArrayRef->check(undef) => 'Optional is NOT allowed to be undef';
ok $Optional_ArrayRef->check([1,2,3]) => 'Correctly validates [1,2,3]';
ok !$Optional_ArrayRef->check("a") => 'Correctly fails "a"';
ok !$Optional_ArrayRef->check(["a","b"]) => 'Correctly fails ["a","b"]';