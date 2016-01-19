interface( quiet=true ):

Digits    := 10:
threshold := 1^(-8);

alpha := sqrt(3.) - sqrt(2.):

xx  := map( evalf, [alpha, alpha^2, alpha^3] ); 

gmma := 2/sqrt(3.):

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
    s[k] := sqrt( add(xx[j]^2,j=k..n) );
end do:
s := convert(s, list):

t := 1/s[1]:

for k from 1 to n do
    yy[k] := t*xx[k];
    s[k] := t*s[k];
end do:
yy := convert(yy,list):
s := convert(s,list):

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


#Reduce H
for i from 2 to n do
    for j from i-1 to 1 by -1 do
        t := round( H[i,j]/H[j,j] );
        yy[j] := yy[j] + t*yy[i];
        for k from 1 to j do
            H[i,k] := H[i,k] - t*H[j,k];
        end do;
        
        for k from 1 to n do
            A[i,k] := A[i,k] - t*A[j,k];
            B[k,j] := B[k,j] + t*B[k,i];
        end do;
    end do;
end do:

#lprint( xx );
lprint( yy );
#print( H );

for vrb from 1 to 11 do
    
    #ITERATION
    m,t := 0,0:
    for i from 1 to n-1 do
        if  t < gmma^i*abs( H[i,i] ) then
            t := gmma^i*abs( H[i,i] );
            m := i;
        end if;
    end do:
    
    #SwapRows
    yy[m], yy[m+1] := yy[m+1], yy[m] :
    
    LinearAlgebra[RowOperation]( A, [m,m+1], inplace=true):
    LinearAlgebra[RowOperation]( H, [m,m+1], inplace=true):
    LinearAlgebra[ColumnOperation]( B, [m,m+1], inplace=true):
    
    #Remove corner on H diagonal
    if m <= n-2 then
        t[0] := sqrt( H[m,m]^2 + H[m,m+1]^2 );
        t[1] := H[m,m] / t[0];
        t[2] := H[m,m+1]/t[0];
        
        for i from m to n do
            t[3] := H[i,m];
            t[4] := H[i,m+1];
            H[i,m]   := t[1]*t[3] + t[2]*t[4];
            H[i,m+1] := -t[2]*t[3] + t[1]*t[4];
        end do:
    end if:
    
    #Reduce H
    for i from m+1 to n do
        for j from min(i-1,m+1) to 1 by -1 do
            t := round(H[i,j]/H[j,j]);
            yy[j] := yy[j] + t*yy[i];
            
            for k from 1 to j do
                H[i,k] := H[i,k] - t*H[j,k];
            end do;
            for k from 1 to n do
                A[i,k] := A[i,k] - t*A[j,k];
                B[k,j] := B[k,j] + t*B[k,i];
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
    
    
end do:

quit;