interface( quiet=true ):

Digits := 20;

alpha := sqrt(3.) - sqrt(2.):
xx := [ seq(alpha^i, i=0..4) ]:
n  := nops(xx);

lprint("Initial x vector");
for x in xx do
    lprint( x );
end do;
printf("\n");

for k from 1 to n do
print( k, j, n );
    s[k] := sqrt( add(xx[j]^2,j=k..n) );
end do:
s := convert(s, list);

t := 1/s[1]:

for k from 1 to n do
    y[k] := t*xx[k];
end do:

printf("\n");
for i from 1 to n do
    lprint( y[i] );
end do;