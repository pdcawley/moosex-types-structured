## Test case donated by Stevan Little

BEGIN {
    package Interpreter;
    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Structured qw(Dict Tuple);
    use MooseX::Types::Moose qw(Int Str);
    use MooseX::Types -declare => [qw(
        Var
        Const
        Op
        Expr
    )];

    subtype Var() => as Str();

    subtype Const() => as Int() | Str();

    enum Op() => qw[ + - ^ ];

    subtype Expr() => as
          Const()
        | Tuple([Expr(), Op(), Expr()]) # binop
        | Var();
}

{
    package Foo;
    BEGIN { Interpreter->import(':all') };
    use Test::More 'no_plan';

    ok is_Var('x'), q{passes is_Var('x')};
    ok is_Const(1), q{passes is_Const(1)};
    ok is_Const('Hello World'), q{passes is_Const};

    ok is_Op('+'), q{passes is_Op('+')};
    ok is_Op('-'), q{passes is_Op('-')};
    ok is_Op('^'), q{passes is_Op('^')};

    ok Expr->check([ 11, '+', 12]), '';
    ok is_Expr([ 1, '+', 1]), q{passes is_Expr([ 1, '+', 1])};
    ok is_Expr([ 1, '+', [ 1, '+', 1 ]]), q{passes is_Expr([ 1, '+', [ 1, '+', 1 ]])};
}






