BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>1;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Coerce;

    use Moose;
    use MooseX::Types::Structured qw(Dict Tuple);
	use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef);
	use MooseX::Types -declare => [qw(

    )];
    

}




