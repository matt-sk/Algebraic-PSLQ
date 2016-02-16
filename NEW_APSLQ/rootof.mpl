AlgExpand := proc(x::algebraic, threshold::{float,fraction}, $)::algebraic;
    return AlgTrim(expand(evalf(x,Digits)),threshold);
end proc;


AlgTrim := proc( x::algebraic, threshold::{float,fraction}, $ )::algebraic;
#option trace;
local agbs, pp, ans, i, t;
    
    agbs := GetAllAlgebraics(x);
    pp   := [seq(a^2,a in agbs)];
    ans  := 0;
    
    for i from 0 to 2^nops(pp)-1 do
        t := AlgCoeff( x, term2mono(i,pp) );
        if abs(t) <= threshold then
            next;
        end if;
        ans := ans + t*term2mono(i,pp);
    end do;
    return ans;
end proc;


AlgSqrt := proc( x::algebraic )::algebraic;
description "Numerical determine the square root of an algebraic number.";
option trace;
local agbs, pp, n, v, Vsqrd, i, sys, V;
    
    agbs := GetAllAlgebraics(x);
    pp   := [seq(a^2,a in agbs)];
    n    := nops(pp);
    
    if n = 0 then return sqrt(x); end if;
    
    V     := add( v[i]*term2mono(i,pp), i = 0..2^n-1 );
    Vsqrd := expand( V^2 ):
    
    for i from 0 to 2^n-1 do
        sys[i] := AlgCoeff( x, term2mono(i,pp) ) - AlgCoeff( Vsqrd, term2mono(i,pp) );
    end do:
    
    sys := convert(sys,list);
    #DO SOMEHTHING IF THIS FAILS
    assign( fsolve(sys) );
    
    return add(v[i]*term2mono(i,pp), i=0..2^n-1);
    
end proc:

AlgSqrt2 := proc( x::algebraic, $ )
description "For x = x0 + x1 I only";
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
#option trace;
local agbs;
    
    agbs := Algebraic[GetAlgebraics]( x );
    if not Im(x) = 0 then
        agbs := convert( agbs, set );
        agbs := agbs union {I};
        agbs := convert(agbs, list );
    end if;
    
    return agbs;
    
end proc;


term2mono := proc(i::nonnegint, pp::list(integer)) 
description "Gives ith mononomial of [x1,x2,...,xn]";
#option trace;
local bd;
    if nops(pp) = 0 then return 1; end if;
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
#option trace;
local d, n, agbs;
    
    agbs := GetAllAlgebraics( x );
    n    := nops(agbs);
    
    if nops( agbs ) = 0 then
        return 1/x;
    end if;
    
    d := thisproc(expand(x*eval(x,agbs[1]=-agbs[1])));
    return expand( eval(x,agbs[1]=-agbs[1])*d );
    
end proc:


AlgDivide := proc( x::algebraic, y::algebraic )::algebraic;
    return expand( x*AlgInvert(y) );
end proc;


AlgNearest := proc( x::complex, D::prime, $ )::algebraic;
#option trace;
local alpha, beta, a, b;
    
    if -D mod 4 <> 2 and -D mod 4 <> 3 then
        warning("AlgNearest not yet implemented for D = 1 mod 4");
    end if;
    
    alpha := Re(x);
    beta  := Im(x);
    
    a := round( alpha );
    b := round( beta/sqrt(D) );
    
    return a + b*sqrt(-D);
    
end proc:


AlgNearest2 := proc( a::algebraic )
#option trace;
local agbs, f, swp;
    
    agbs := GetAllAlgebraics( a );
    if nops(agbs) = 0 then return round(a); end if;
    
    agbs := [seq(agbs[i-1]=x^i,i=2..nops(gbs)+1)];
    f    := eval( a, agbs );
    f    := add( round(coeff(f,x,i))*x^i,i=0..nops(agbs) );
    swp  := x -> rhs(x) = lhs(x);
    
    return eval( f, map(swp,agbs) );

end proc: