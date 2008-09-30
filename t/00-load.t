use strict;
use warnings;

use Test::More tests=>2;

## List all the modules we want to make sure can at least compile
use_ok 'MooseX::Meta::TypeConstraint::Structured';
use_ok 'MooseX::Types::Structured';