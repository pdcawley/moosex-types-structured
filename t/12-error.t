BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>4;
}

use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw(Dict Tuple);
use MooseX::Types::Moose qw(Int Str ArrayRef HashRef);

# Create some TCs from which errors will be generated
my $simple_tuple = subtype 'simple_tuple', as Tuple[Int,Str];
my $simple_dict = subtype 'simple_dict', as Dict[name=>Str,age=>Int];

# We probably need more stuff here...
ok $simple_tuple->check([1,'hello']), "simple_tuple validates: 1,'hello'";
ok !$simple_tuple->check(['hello',1]), "simple_tuple fails: 'hello',1";
like $simple_tuple->validate(['hello',1]), qr/"hello", 1/, 'got expected valiate message';
like $simple_dict->validate(['hello',1]), qr/"hello", 1/, 'got expected valiate message';

