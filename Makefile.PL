use inc::Module::Install;

## All the required meta information
name 'MooseX-Types-Structured';
all_from 'lib/MooseX/Types/Structured.pm';
abstract 'Moose Type Constraint classes for Structured Types';
author 'John Napiorkowski <jjnapiork@cpan.org>';
license 'perl';

## Module dependencies
requires 'Moose' => '0.63';
requires 'MooseX::Types' => '0.08';
requires 'Devel::PartialDump' => '0.07';
requires 'Sub::Exporter' => '0.982';

## Testing dependencies
build_requires 'Test::More' => '0.70';
build_requires 'Test::Exception' => '0.27';

## Author tests dependencies
author_requires 'Test::Pod' => '1.14';
author_requires 'Test::Pod::Coverage' => '1.08';

## Build README
system 'pod2text lib/MooseX/Types/Structured.pm > README'
    if -e 'MANIFEST.SKIP';
    
## Instructions to Module::Install
auto_install;
tests_recursive;
WriteAll;

1;
