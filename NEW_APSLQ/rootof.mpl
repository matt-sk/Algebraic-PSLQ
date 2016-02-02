AlgSqrt := proc( x::algebraic, $ )
description "Find y::algebraic so that y^2 = x";
#option trace;
local agbs, p, w, v;
    
    agbs := GetAllAlgebraics(x);
    if agbs = {} then
        return sqrt(x);
    elif nops(agbs) > 1 then 
        error "Square-roots not yet implented for >1 affixes";
    end if;
    
    p    := agbs[1]^2;
    
    w[0] := AlgCoeff( x, 1 );
    w[1] := AlgCoeff( x, agbs[1] );
    
    v[1] := (1/2)*2^(1/2)*(p*(w[0]+(-w[1]^2*p+w[0]^2)^(1/2)))^(1/2)/p;
    v[1] := evalf( v[1] );
    v[0] := 2*v[1]*(-p*v[1]^2+w[0])/w[1];
    v[0] := evalf( v[0] );
    return expand( v[0] + v[1]*agbs[1] );
    
end proc:


GetAllAlgebraics := proc( x )
description "Hack for including i when it has a float coefficient";
local agbs;
    
    agbs := Algebraic[GetAlgebraics]( x );
    if not Im(x) = 0 then
        agbs := convert( agbs, set );
        agbs := agbs union {I};
        agbs := convert(agbs, list );
    end if;
    
    return agbs;
    
end proc;


term2mono := proc(i::nonnegint, p::list(integer)) 
description "Gives ith mononomial of [x1,x2,...,xn]";
#option trace;
local bd;
    bd := convert( i, base, 2 );
    `*`( seq( sqrt(pp[j])^bd[j],j=1..nops(bd)) );
end proc:


AlgCoeff := proc( W::algebraic, V::algebraic )
#Recover the cofficient of W on monomial V
#option trace;
local ans, x;
    
    if type(V,integer) then
        return subs( seq(a=0, a in GetAllAlgebraics( W )), W);
    end if;
    
    ans := subs( seq(a=x, a in GetAllAlgebraics( V )), W);
    ans := coeff( ans, x, nops( GetAllAlgebraics( V ) ) );
    return subs( seq(a=0, a in GetAllAlgebraics( W )), ans);
    
end proc:


AlgAbs := proc( x::algebraic )::algebraic;
#option trace;
local d, n, agbs;
    
    agbs := GetAllAlgebraics( x );
    return sqrt(add( AlgCoeff( x, a )^2, a in agbs)+AlgCoeff(x, 1)^2);
    
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
local d, n, agbs;
    
    agbs := Algebraic[GetAlgebraics]( x );
    
    if nops( agbs ) = 0 then
        return 1/x;
    end if;
    
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