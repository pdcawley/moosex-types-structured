BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>16;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Advanced;

    use Moose;
    use MooseX::Types::Structured qw(Dict Tuple);
	use MooseX::Types::Moose qw(Int Str Object ArrayRef HashRef Maybe);
	use MooseX::Types -declare => [qw(
        EqualLength MoreThanFive MoreLengthPlease PersonalInfo MorePersonalInfo
        MinFiveChars
    )];
    
    subtype MoreThanFive,
     as Int,
     where { $_ > 5};
	
    ## Tuple contains two equal length Arrays
    subtype EqualLength,
     as Tuple[ArrayRef[MoreThanFive],ArrayRef[MoreThanFive]],
     where { $#{$_->[0]} == $#{$_->[1]} };
     
    ## subclass the complex tuple
    subtype MoreLengthPlease,
     as EqualLength,
     where { $#{$_->[0]} >= 4};

    ## Complexe Dict
    subtype PersonalInfo,
     as Dict[name=>Str, stats=>MoreLengthPlease|Object];
     
    ## Minimum 5 char string
    subtype MinFiveChars,
     as Str,
     where { length($_) > 5};    
    
    ## Dict key overloading
    subtype MorePersonalInfo,
     as PersonalInfo[name=>MinFiveChars, stats=>MoreLengthPlease|Object];
    
    has 'EqualLengthAttr' => (is=>'rw', isa=>EqualLength);
    has 'MoreLengthPleaseAttr' => (is=>'rw', isa=>MoreLengthPlease);
    has 'PersonalInfoAttr' => (is=>'rw', isa=>PersonalInfo);
    has 'MorePersonalInfo' => (is=>'rw', isa=>MorePersonalInfo);
}

## Instantiate a new test object

ok my $obj = Test::MooseX::Meta::TypeConstraint::Structured::Advanced->new
 => 'Instantiated new Record test class.';
 
isa_ok $obj => 'Test::MooseX::Meta::TypeConstraint::Structured::Advanced'
 => 'Created correct object type.';
  
## Test EqualLengthAttr

lives_ok sub {
    $obj->EqualLengthAttr([[6,7,8],[9,10,11]]);
} => 'Set EqualLengthAttr attribute without error';

throws_ok sub {
    $obj->EqualLengthAttr([1,'hello', 'test.xxx.test']);    
}, qr/Attribute \(EqualLengthAttr\) does not pass the type constraint/
 => q{EqualLengthAttr correctly fails [1,'hello', 'test.xxx.test']};
 
throws_ok sub {
    $obj->EqualLengthAttr([[6,7],[9,10,11]]);    
}, qr/Attribute \(EqualLengthAttr\) does not pass the type constraint/
 => q{EqualLengthAttr correctly fails [[6,7],[9,10,11]]};
 
throws_ok sub {
    $obj->EqualLengthAttr([[6,7,1],[9,10,11]]);    
}, qr/Attribute \(EqualLengthAttr\) does not pass the type constraint/
 => q{EqualLengthAttr correctly fails [[6,7,1],[9,10,11]]};
 
## Test MoreLengthPleaseAttr

lives_ok sub {
    $obj->MoreLengthPleaseAttr([[6,7,8,9,10],[11,12,13,14,15]]);
} => 'Set MoreLengthPleaseAttr attribute without error';

throws_ok sub {
    $obj->MoreLengthPleaseAttr([[6,7,8,9],[11,12,13,14]]);    
}, qr/Attribute \(MoreLengthPleaseAttr\) does not pass the type constraint/
 => q{MoreLengthPleaseAttr correctly fails [[6,7,8,9],[11,12,13,14]]};
 
## Test PersonalInfoAttr

lives_ok sub {
    $obj->PersonalInfoAttr({name=>'John', stats=>[[6,7,8,9,10],[11,12,13,14,15]]});
} => 'Set PersonalInfoAttr attribute without error 1';

lives_ok sub {
    $obj->PersonalInfoAttr({name=>'John', stats=>$obj});
} => 'Set PersonalInfoAttr attribute without error 2';

throws_ok sub {
    $obj->PersonalInfoAttr({name=>'John', stats=>[[6,7,8,9],[11,12,13,14]]});    
}, qr/Attribute \(PersonalInfoAttr\) does not pass the type constraint/
 => q{PersonalInfoAttr correctly fails name=>'John', stats=>[[6,7,8,9],[11,12,13,14]]};

throws_ok sub {
    $obj->PersonalInfoAttr({name=>'John', extra=>1, stats=>[[6,7,8,9,10],[11,12,13,14,15]]});    
}, qr/Attribute \(PersonalInfoAttr\) does not pass the type constraint/
 => q{PersonalInfoAttr correctly fails name=>'John', extra=>1, stats=>[[6,7,8,9,10],[11,12,13,14,15]]};

## Test MorePersonalInfo

lives_ok sub {
    $obj->MorePersonalInfo({name=>'Johnnap', stats=>[[6,7,8,9,10],[11,12,13,14,15]]});
} => 'Set MorePersonalInfo attribute without error 1';

throws_ok sub {
    $obj->MorePersonalInfo({name=>'Johnnap', stats=>[[6,7,8,9],[11,12,13,14]]});    
}, qr/Attribute \(MorePersonalInfo\) does not pass the type constraint/
 => q{MorePersonalInfo correctly fails name=>'Johnnap', stats=>[[6,7,8,9],[11,12,13,14]]};

throws_ok sub {
    $obj->MorePersonalInfo({name=>'Johnnap', extra=>1, stats=>[[6,7,8,9,10],[11,12,13,14,15]]});    
}, qr/Attribute \(MorePersonalInfo\) does not pass the type constraint/
 => q{MorePersonalInfo correctly fails name=>'Johnnap', extra=>1, stats=>[[6,7,8,9,10],[11,12,13,14,15]]};

throws_ok sub {
    $obj->MorePersonalInfo({name=>'.bc', stats=>[[6,7,8,9,10],[11,12,13,14,15]]});    
}, qr/Attribute \(MorePersonalInfo\) does not pass the type constraint/
 => q{MorePersonalInfo correctly fails name=>'.bc', stats=>[[6,7,8,9,10],[11,12,13,14,15]]};   


