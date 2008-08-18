use inc::Module::Install;

## All the required meta information
all_from 'lib/MooseX/Meta/TypeConstraint/Structured.pm';

## Module dependencies
requires 'Moose' => '0.54';

## Testing dependencies
build_requires 'Test::More' => '0.70';
build_requires 'Test::Exception' => '0.27';
build_requires 'Test::Pod' => '1.14';
build_requires 'Test::Pod::Coverage' => '1.08';

## Instructions to Module::Install
auto_install;
tests_recursive;
WriteAll;

1;
