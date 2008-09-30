use strict;
use warnings;

use Test::More tests=>14;

use_ok 'MooseX::Meta::TypeConstraint::Structured';
use_ok 'Moose::Util::TypeConstraints';

ok my $int = find_type_constraint('Int') => 'Got Int';
ok my $str = find_type_constraint('Str') => 'Got Str';
ok my $arrayref = find_type_constraint('ArrayRef') => 'Got ArrayRef';

my $list_tc = MooseX::Meta::TypeConstraint::Structured->new(
    name => 'list_tc',
    parent => $arrayref,
    type_constraints => [$int, $str],
    constraint_generator=> sub {
        my @type_constraints = @{shift @_};            
        my @values = @{shift @_};

        while(my $type_constraint = shift @type_constraints) {
            my $value = shift @values || return;
            $type_constraint->check($value) || return;
        }
        if(@values) {
            return;
        } else {
            return 1;
        }
    }
);

isa_ok $list_tc, 'MooseX::Meta::TypeConstraint::Structured';

ok !$arrayref->check() => 'Parent undef fails';
ok !$list_tc->check() => 'undef fails';
ok !$list_tc->check(1) => '1 fails';
ok !$list_tc->check([]) => '[] fails';
ok !$list_tc->check([1]) => '[1] fails';
ok !$list_tc->check([1,2,3]) => '[1,2,3] fails';
ok !$list_tc->check(['a','b']) => '["a","b"] fails';

ok $list_tc->check([1,'a']) => '[1,"a"] passes';
