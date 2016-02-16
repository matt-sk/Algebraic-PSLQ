interface(quiet=true):
read "rootof.mpl":

Digits := 10:

P := 7;

AlgNearest := proc( x::complex, D::prime, $ )::algebraic;
option trace;
local alpha, beta, a, b;
    
    if -D mod 4 <> 2 and -D mod 4 <> 3 then
        error "AlgNearest not yet implemented for D = 1 mod 4";
    end if;
    
    alpha := Re(x);
    beta  := Im(x);
    
    a := round( alpha );
    b := round( beta/sqrt(D) );
    
    return a + b*sqrt(-D);
    
end proc:

x := 4*ln(2) + I*Pi:
x := evalf( x );

AlgNearest( x, 5 );

quit;

Digits := 10;

pp := [ -1, 2 ]:
n := nops(pp):

assign( seq( w[i] = evalf(i+1), i = 0..2^n-1 ) );

#for i from 0 to 2^n-1 do
#    assume( w[i], real );
#end do;

W := add( w[i]*term2mono(i,pp), i = 0..2^n-1 );

AlgInvert( W ) * W;
expand( W*AlgInvert( W ) );

#V := AlgSqrt( W );
#V := expand( V^2 );

quit;
