BEGIN {
	use strict;
	use warnings;
	use Test::More tests=>3;
}

## This is a first pass at what the regex enhancements to
## Moose::Util::TypeConstraints is going to look like.  Basically I copyied
## bits and added a little more parsing ability.
 
{
    ## Copied from Moose::Util::TypeConstraints
    use re "eval";

    my $any;
    my $valid_chars = qr{[\w:]};
    my $type_atom   = qr{ $valid_chars+ };
    
    my $type                = qr{  $valid_chars+  (?: \[  (??{$any})  \] )? }x;
    my $type_capture_parts  = qr{ ($valid_chars+) (?: \[ ((??{$any})) \] )? }x;
    my $type_with_parameter = qr{  $valid_chars+      \[  (??{$any})  \]    }x;
    
    my $op_union = qr{ \s* \| \s* }x;
    my $union    = qr{ $type (?: $op_union $type )+ }x;
    
    ## New Stuff for structured types.
    my $comma = qr{,};
    my $indirection = qr{=>};
    my $divider_ops = qr{ $comma | $indirection }x;
    my $structure_divider = qr{\s* $divider_ops \s*}x;    
    my $structure_elements = qr{ ($type $structure_divider*)+ }x;

	## Addd the | $structure_elements to this.
    $any = qr{ $type | $union | $structure_elements }x;
    
    ## New Proposed methods to parse and create
    sub _parse_structured_type_constraint {
        { no warnings 'void'; $any; } # force capture of interpolated lexical
        
        my($base, $elements) = ($_[0] =~ m{ $type_capture_parts }x);
        return ($base, [split($structure_divider, $elements)]);
    }
    
    is_deeply
        [_parse_structured_type_constraint('ArrayRef[Int,Str]')],
        ["ArrayRef", ["Int", "Str"]]
     => 'Correctly parsed ArrayRef[Int,Str]';
     
    is_deeply
        [_parse_structured_type_constraint('ArrayRef[ArrayRef[Int],Str]')],
        ["ArrayRef", ["ArrayRef[Int]", "Str"]]
     => 'Correctly parsed ArrayRef[ArrayRef[Int],Str]';
         
    is_deeply 
        [_parse_structured_type_constraint('HashRef[key1 => Int, key2=>Int, key3=>ArrayRef[Int]]')],
        ["HashRef", ["key1", "Int", "key2", "Int", "key3", "ArrayRef[Int]"]]
     => 'Correctly parsed HashRef[key1 => Int, key2=>Int, key3=>ArrayRef[Int]]';

}
 