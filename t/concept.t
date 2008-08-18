BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>17;
	use Test::Exception;
}

{
    package Test::MooseX::Meta::TypeConstraint::Structured::Concept;

    use Moose;
    use Moose::Util::TypeConstraints;
    
    sub _normalize_args {
        if(defined $_[0] && ref $_[0] eq 'ARRAY') {
            return @{$_[0]};
        } else {
            confess 'Arguments not normal';
        }
    }

    sub Pair {
        my ($canonical_key, $value) = _normalize_args(shift);
        return subtype
            as "HashRef[$value]",
            where {
                my ($key, $extra) = keys %$_;
                ($key eq $canonical_key) && !$extra;
            };
    }
      
    sub Tuple {
        my @args = _normalize_args(shift);
        return subtype
         as 'ArrayRef',
         where {
            my @incoming = @$_;
            foreach my $idx (0..$#args) {
                find_type_constraint($args[$idx])->check($incoming[$idx]) ||
                 confess 'Trouble validating Tuple';
            } 1;
         };
    }
    
    sub Dict {
        my %keys_typeconstraints = _normalize_args(shift);
        return subtype
         as 'HashRef',
         where {
            my %incoming = %$_;
            foreach my $key (keys %keys_typeconstraints) {
                my $type_constraint = $keys_typeconstraints{$key};
                my $incoming = $incoming{$key} || confess "Missing $key";
                find_type_constraint($type_constraint)->check($incoming)
                 || confess "Trouble validating Dictionary";                
            } 1;
         };
    }
    
    has 'pair' => (is=>'rw', isa=>Pair[key=>'Str']);
    has 'tuple' => (is=>'rw', isa=>Tuple['Int', 'Str']);
    has 'dict' => (is=>'rw', isa=>Dict[name=>'Str', age=>'Int']);
}

## Instantiate a new test object

ok my $record = Test::MooseX::Meta::TypeConstraint::Structured::Concept->new
 => 'Instantiated new Record test class.';
 
isa_ok $record => 'Test::MooseX::Meta::TypeConstraint::Structured::Concept'
 => 'Created correct object type.';
 
## Test the Pair type constraint

lives_ok sub {
    $record->pair({key=>'value'});
} => 'Set pair attribute without error';

is $record->pair->{key}, 'value'
 => 'correctly set the pair attribute';
 
throws_ok sub {
    $record->pair({not_the_key=>'value'}) ;      
}, qr/Validation failed/
 => 'Got Expected Error for bad key';
 
throws_ok sub {
    $record->pair({key=>[1,2,3]}) ;      
}, qr/Validation failed/
 => 'Got Expected Error for bad value';

## Test the Tuple type constraint

lives_ok sub {
    $record->tuple([1,'hello']);
} => 'Set tuple attribute without error';

is $record->tuple->[0], 1
 => 'correct set the tuple attribute index 0';

is $record->tuple->[1], 'hello'
 => 'correct set the tuple attribute index 1';
 
throws_ok sub {
    $record->tuple('hello') ;      
}, qr/Validation failed/
 => 'Got Expected Error when setting as a scalar';
 
throws_ok sub {
    $record->tuple({key=>[1,2,3]}) ;      
}, qr/Validation failed/
 => 'Got Expected Error for trying a hashref ';

throws_ok sub {
    $record->tuple(['asdasd',2]) ;      
}, qr/Trouble validating Tuple/
 => 'Got Expected Error for violating constraints';
 
## Test the Dictionary type constraint
 
lives_ok sub {
    $record->dict({name=>'frith', age=>23});
} => 'Set dict attribute without error';

is $record->dict->{name}, 'frith'
 => 'correct set the dict attribute name';

is $record->dict->{age}, 23
 => 'correct set the dict attribute age';
 
throws_ok sub {
    $record->dict('hello') ;      
}, qr/Validation failed/
 => 'Got Expected Error for bad key in dict';
 
throws_ok sub {
    $record->dict({name=>[1,2,3], age=>'sdfsdfsd'});      
}, qr/Trouble validating Dictionary/
 => 'Got Expected Error for bad value in dict';
 
