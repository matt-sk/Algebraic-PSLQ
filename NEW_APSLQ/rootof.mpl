AlgSqrt := x -> x ;


term2mono := proc(i::nonnegint) 
description "Gives ith mononomial of [x1,x2,...,xn]";
#option trace;
local bd;
    bd := convert( i, base, 2 );
    `*`( seq( sqrt(pp[j])^bd[j],j=1..nops(bd)) );
end proc:

AlgCoeff := proc( W::algebraic, V::algebraic )
#option trace;
local ans;
    
    if type(V,integer) then
        return subs( seq(a=0, a in Algebraic[GetAlgebraics]( W )), W);
    end if;
    
    ans := subs( seq(a=x, a in Algebraic[GetAlgebraics]( V )), W);
    ans := coeff( ans, x, nops( Algebraic[GetAlgebraics]( V ) ) );
    return subs( seq(a=0, a in Algebraic[GetAlgebraics]( W )), ans);
    
end proc:


AlgAbs := proc( x::algebraic )::algebraic;
option trace;
local d, n, agbs;
    
    algbs := Algebraic[GetAlgebraics]( x );
    if not Re(x) = 0 then
        algbs := convert( algbs, set );
        algbs := algbs union {I};
        algbs := convert(algbs, list );
    end if;
    
    return sqrt(add( AlgCoeff( x, a )^2, a in algbs));
    
end proc:


AlgConj := proc( x::algebraic )::algebraic;
#option trace;
local t, agbs;
    
    #hack to fix Algebraic[GetAlgebraics](1.0*I) 
    if Im(x) <> 0 then
        t :=  eval(x, I=-I);
        return expand(t*thisproc(evalc( x*t )));
    end if;
    
    agbs := Algebraic[GetAlgebraics]( x );
    if nops(agbs) = 0 then
        return x;
    end if;
    
    t :=  expand(eval(x, agbs[1]=-agbs[1]));
    return expand(t*thisproc(expand( x*t )));
end proc:

AlgInvert := proc( x::algebraic )::algebraic;
#option trace;
local d, n, agbs;
    
    agbs := Algebraic[GetAlgebraics]( x );
    
    if nops( agbs ) = 0 then
        return 1/x;
    end if;
    
    n := eval(x,agbs[1]=-agbs[1]);
    d := thisproc(expand(x*eval(x,agbs[1]=-agbs[1])));
    
    return expand( n*d );
    
end proc:

AlgDivide := proc( x::algebraic, y::algebraic )::algebraic;
    return expand( x*AlgInvert(y) );
end proc;

AlgNearest := proc( a::algebraic )
#option trace;
local agbs, f, swp;
    
    agbs := Algebraic[GetAlgebraics]( a );
    
    if agbs = {} then
        agbs := [I=x];
    else
        agbs := [seq(agbs[i-1]=x^i,i=2..nops(gbs)+1),I=x];
    end if;
    f    := eval( a, agbs );
    f    := add( round(coeff(f,x,i))*x^i,i=0..nops(agbs) );
    swp  := x -> rhs(x) = lhs(x);
    
    return eval( f, map(swp,agbs) );

end proc: