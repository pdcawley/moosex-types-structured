BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>4;
	use Test::Exception;
	
	use_ok 'Moose::Util::TypeConstraints';
	use_ok 'MooseX::Meta::TypeConstraint::Structured::Positionable';	
}

ok my $REGISTRY = Moose::Meta::TypeConstraint::Registry->new
 => 'Got a registry';
 
my $tuple = MooseX::Meta::TypeConstraint::Structured::Positionable->new(
		name => 'Tuple',
		package_defined_in => __PACKAGE__,
		parent => find_type_constraint('Ref'),
	);


type('Tuple', $tuple);




use Data::Dump qw/dump/;
#warn dump sort {$a cmp $b} Moose::Util::TypeConstraints::list_all_type_constraints;


{
	package Test::MooseX::Types::Structured::Positionable;
	use Moose;
	
	has 'attr' => (is=>'rw', isa=>'Tuple[Int,Str,Int]');
	
}

ok my $positioned_obj = Test::MooseX::Types::Structured::Positionable->new,
 => 'Got a good object';

## should be good
$positioned_obj->attr([1,'hello',3]);

## should all fail
$positioned_obj->attr([1,2,'world']);
$positioned_obj->attr(['hello',2,3]);
$positioned_obj->attr(['hello',2,'world']);