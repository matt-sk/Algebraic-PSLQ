AlgNearest := proc( x::complex, D::integer, $ )::algebraic;
#option trace;
local alpha, beta, a, b, omega;
    
    alpha := Re(x);
    beta  := Im(x);
    
    if -D mod 4 = 1 then
#        b := round( 2*beta / sqrt(D) );
#        a := round( (2*alpha-b)/sqrt(D) );
        
        b := evalf( 2*beta / sqrt(D) );
        if b > 0 then
            b := trunc( b + 0.5 );
        else
            b := -trunc( -b + 0.5 );
        end if;
        
        a := evalf( (2*alpha-b)/sqrt(D) );
        if a > 0 then
            a := trunc( a + 0.5 );
        else
            a := -trunc( -a + 0.5 );
        end if;
        
        
        omega := (1+sqrt(-D))/2;
    else
        
        a := alpha;
        if a > 0 then
            a := trunc( a + 0.5 );
        else
            a := -trunc( -a + 0.5 );
        end if;
        
        b := evalf( beta/sqrt(D) );
        if b > 0 then
            b := trunc( b + 0.5 );
        else
            b := -trunc( -b + 0.5 );
        end if;
        
        omega := sqrt(-D);
    end if;
    
    return a + b*omega;
    
end proc:
