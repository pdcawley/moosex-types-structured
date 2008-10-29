use inc::Module::Install;

## All the required meta information
name     'MooseX-Types-Structured';
all_from 'lib/MooseX/Types/Structured.pm';
abstract 'Moose Type Constraint classes for Structured Types';
author 'John Napiorkowski <jjnapiork@cpan.org>';
license 'perl';

## Module dependencies
requires 'Moose' => '0.60';
requires 'MooseX::Types' => '0.06';

## Testing dependencies
build_requires 'Test::More' => '0.70';
build_requires 'Test::Exception' => '0.27';
build_requires 'Test::Pod' => '1.14';
build_requires 'Test::Pod::Coverage' => '1.08';

## Build README
system 'pod2text lib/MooseX/Types/Structured.pm > README'
    if -e 'MANIFEST.SKIP';
    
## Instructions to Module::Install
auto_install;
tests_recursive;
WriteAll;

1;
