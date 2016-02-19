APSLQ := proc( inxx::{list(complex),vector(complex)}, D::posint, { iterations := 1000, digits := 100, gmma :=  2/sqrt(3.),  threshold := 10^( -trunc(.24*Digits) ) }, $)::list(integer);
#option trace;
description "APSLQ over Q[sqrt(-D)]";
local A, B, H, ii, i, j, k, n, s, t, xx, yy, vrb, m, M, miny, pos, prev_m := 1, tmp;
    
    if Digits > digits then WARNING("PSLQ is using less digits than session."); fi;
    
    Digits := digits;
    xx := map(evalf,inxx,digits);
    
    #Initialization
    n := nops(xx):
    A := Matrix(n,n):
    B := Matrix(n,n):
    for i from 1 to n do
        for j from 1 to n do
            if i = j then
                A[i,j] := 1;
                B[i,j] := 1;
            else
                A[i,j] := 0;
                B[i,j] := 0;
            end if;
        end do;
    end do:
    
    for k from 1 to n do
        s[k] := add( xx[j]*xx[j], j=k..n );
        s[k] := evalf( sqrt(s[k]) );
    end do:
    s := convert(s, list);
        
    t := evalf( 1/s[1] );
    
    for k from 1 to n do
        yy[k] := expand( t*xx[k] );
        s[k]  := expand( t*s[k]  );
    end do:
    yy := convert(yy,list):
    s  := convert(s,list):
    
    #Initialize H
    H := Matrix( n, n-1 ):
    for j from 1 to n-1 do
        for i from 1 to j-1 do
            H[i,j] := 0;
        end do;
        
        H[j,j] := s[j+1]/s[j];
        
        for i from j+1 to n do 
            H[i,j] := -yy[i]*yy[j]/s[j]/s[j+1];
        end do;
    end do:
    
    H := map( evalf, H );
    
    #Reduce H
    for i from 2 to n do
        for j from i-1 to 1 by -1 do
            
            t := AlgNearest( evalf(H[i,j]/H[j,j]), D );
            yy[j] := evalf( yy[j] + t*yy[i] );
            
            for k from 1 to j do
                H[i,k] := evalf( H[i,k] - t*H[j,k] );
            end do;
            
            for k from 1 to n do
                A[i,k] := expand( A[i,k] - t*A[j,k] );
                B[k,j] := expand( B[k,j] + t*B[k,i] );
            end do;
        end do;
    end do:
    
    for ii from 1 to iterations do
        #ITERATION
        m,t := 0,0:
        
        for i from 1 to n-1 do
            if i = prev_m then next; fi;
            if t < gmma^i*abs( H[i,i] ) then
                t := gmma^i*abs( H[i,i] );
                m := i;
            end if;
        end do:
        
        #SwapRows
        if m = nops(yy) then
            error "ran out of row swaps";
        end if; 
        
        yy[m], yy[m+1] := yy[m+1], yy[m] :
        prev_m := m;
        
        LinearAlgebra[RowOperation]( A, [m,m+1], inplace=true):
        LinearAlgebra[RowOperation]( H, [m,m+1], inplace=true):
        LinearAlgebra[ColumnOperation]( B, [m,m+1], inplace=true):
        
        #Remove corner on H diagonal
        if m <= n-2 then
            t[0] := sqrt( H[m,m]^2 + H[m,m+1]^2 );
            t[1] := H[m,m]/t[0];
            t[2] := H[m,m+1]/t[0];
            
            for i from m to n do
                t[3] := H[i,m];
                t[4] := H[i,m+1];
                H[i,m]   :=  t[1]*t[3] + t[2]*t[4];
                H[i,m+1] := -t[2]*t[3] + t[1]*t[4];
            end do:
        end if:
        
        H := map( evalf, H );
        
        #Reduce H
        for i from m+1 to n do
            for j from min(i-1,m+1) to 1 by -1 do
                t := AlgNearest( H[i,j]/H[j,j], D );
                yy[j] := evalf( yy[j] + t*yy[i] );
                
                for k from 1 to j do
                    H[i,k] := evalf( H[i,k] - t*H[j,k] );
                end do;
                
                for k from 1 to n do
                    A[i,k] := expand( A[i,k] - t*A[j,k] );
                    B[k,j] := expand( B[k,j] + t*B[k,i] );
                end do;
            end do;
        end do;
        
        #NORM BOUND
        M := 0:
        for j from 1 to nops(xx)-1 do
            if abs(eval(1/H[j,j])) > M then
                M := abs(eval(1/H[j,j]));
            end if;
        end do:
        
        miny, pos := ListTools[FindMinimalElement]( map( abs, map(evalf,yy)), position );
#this shows current level.
#tmp := convert( LinearAlgebra[Column]( B, pos ), list );
#lprint( evalf( abs(expand(add( xx[i]*tmp[i], i=1..nops(xx) ))) ) );
        
        if evalf(abs( add( LinearAlgebra[Column]( B, pos )[i]*xx[i], i = 1.. nops(xx) ))) < threshold then
#            lprint( TotalIterations=ii );
            printf("TotalIterations = %a to %a digits\n",ii,Digits);
            return convert( LinearAlgebra[Column]( B, pos ), list );
        end if;
        
    end do:
    
#    lprint(TotalIterations=ii);
#    printf("TotalIterations = %a to %a digits\n ",ii,Digits);
#    return convert( LinearAlgebra[Column]( B, pos ), list );
#    lprint(FAIL);
#    return [infinity$nops(xx)];
    return FAIL;
    
end proc;