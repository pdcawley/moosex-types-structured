BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>20;
}

use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw(Dict Tuple);
use MooseX::Types::Moose qw(Int Str ArrayRef HashRef);

my $array_tailed_tuple =
    subtype 'array_tailed_tuple',
     as Tuple[
        Int,
        Str,
        sub {
            (ArrayRef[Int])->check([@_]);
        },
     ];
  
ok !$array_tailed_tuple->check(['ss',1]), 'correct fail';
ok $array_tailed_tuple->check([1,'ss']), 'correct pass';
ok !$array_tailed_tuple->check({}), 'correct fail';
ok $array_tailed_tuple->check([1,'hello',1,2,3,4]), 'correct pass with tail';
ok !$array_tailed_tuple->check([1,'hello',1,2,'bad',4]), 'correct fail with tail';

my $hash_tailed_tuple =
    subtype 'hash_tailed_tuple',
     as Tuple[
       Int,
       Str,
       sub {
        (HashRef[Int])->check({@_});
       },
     ];

ok !$hash_tailed_tuple->check(['ss',1]), 'correct fail';
ok $hash_tailed_tuple->check([1,'ss']), 'correct pass';
ok !$hash_tailed_tuple->check({}), 'correct fail';
ok $hash_tailed_tuple->check([1,'hello',age=>25,zip=>10533]), 'correct pass with tail';
ok !$hash_tailed_tuple->check([1,'hello',age=>25,name=>'john']), 'correct fail with tail';

my $hash_tailed_dict =
    subtype 'hash_tailed_dict',
    as Dict[
      name=>Str,
      age=>Int,
      sub {
        (HashRef[Int])->check({@_});        
      }
    ];
    
ok !$hash_tailed_dict->check({name=>'john',age=>'napiorkowski'}), 'correct fail';
ok $hash_tailed_dict->check({name=>'Vanessa Li', age=>35}), 'correct pass';
ok !$hash_tailed_dict->check([]), 'correct fail';
ok $hash_tailed_dict->check({name=>'Vanessa Li', age=>35, more1=>1,more2=>2}), 'correct pass with tail';
ok !$hash_tailed_dict->check({name=>'Vanessa Li', age=>35, more1=>1,more2=>"aa"}), 'correct fail with tail';

my $array_tailed_dict =
    subtype 'hash_tailed_dict',
    as Dict[
      name=>Str,
      age=>Int,
      sub {
        (ArrayRef[Int])->check([@_]);       
      }
    ];
    
ok !$array_tailed_dict->check({name=>'john',age=>'napiorkowski'}), 'correct fail';
ok $array_tailed_dict->check({name=>'Vanessa Li', age=>35}), 'correct pass';
ok !$array_tailed_dict->check([]), 'correct fail';
ok $array_tailed_dict->check({name=>'Vanessa Li', age=>35, 1,2}), 'correct pass with tail';
ok !$array_tailed_dict->check({name=>'Vanessa Li', age=>35, 1, "hello"}), 'correct fail with tail';

