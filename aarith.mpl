aabs := proc( in_f::polynom, $ )::polynom;
local f;

    f := Reduce( in_f, 1 );
    
    return sqrt( coeff(f,aa[1],0)^2 + coeff(f,aa[1],1)^2 );
    
end proc;

asqrt := proc( in_f::polynom, $)::polynom;
local f,y,x,s,t;
    
    f := Reduce( in_f, 1 );
    
    y := coeff( in_f, aa[1], 1 );
    x := coeff( in_f, aa[1], 0 );
    
    
    if y = 0 then
        return evalf( sqrt( x ) );
    end if;
    
    s := sqrt( x + sqrt(x^2-pp[1]*y^2) )/sqrt(2);
    t := y/2/s;
    return evalf( s+aa[1]*t );
    
end proc:

adiv := proc( in_f::polynom, in_g::polynom )::polynom;
local f, g, cg;
    
    f := Reduce( in_f, 1 );
    g := Reduce( in_g, 1 );
    
    cg := Conj( in_g, 1 );
    
    return evalf( Reduce( f*cg, 1 )/Reduce(g*cg,1) );
    
end proc;


Reduce := proc( in_x::polynom, n::posint, $ )::polynom;
#option trace;
local x;
    
    x := expand( in_x );
    
    if nargs > 1 then
        return expand( rem( x, aa[n]^2 - pp[n], aa[n] ) );
    end if;
    
    return foldl( thisproc, x, seq(i,i=nops(pp)..1,-1) );
    
end proc:


Conj := proc( in_x::polynom, n::nonnegint, $)::polynom;
local x, xc, t;
    
    if n = 0 then
        return in_x;
    end if;
    
    x  := expand(in_x);
    xc := eval(x, aa[n]=-aa[n]);    #simple conjugate
    
    t := rem(  xc, aa[n]^2-pp[n], aa[n] );
    return rem( t*Conj(x*t,n-1), aa[n]^2-pp[n], aa[n] );
    
end proc:


ANearest := proc( in_x::polynom, $ )::algebraic;
#option trace;
local cs, ts;
    
    cs := coeffs( in_x, aa[1], 'ts' );
    cs := map( round, [cs] );
    ts := [ts];
    
    return add( cs[i]*ts[i], i = 1..nops(ts) );
    
end proc;
