interface(quiet=true):
read "APSLQ.support.mpl":

Digits := 50;


alpha := (1+I)*sqrt(2) + (2+3*I)*ln(2) + I*Pi:
alpha := evalf( alpha );

xx    := [alpha, 1, sqrt(2), ln(2), Pi]:
xx    := evalf( xx );

IntegerRelations[PSLQ]( xx );

APSLQ[APSLQ]( xx );

quit;


alpha := -1/2 + (2 + 3*I*sqrt(5))*Pi + (4 - I*sqrt(5) )*ln(2);
alpha := evalf( alpha );
xx := [ alpha, 1, evalf(Pi), ln(2.)]:

mm := APSLQ[APSLQ]( xx, iterations=100 );

evalf( add(xx[i]*mm[i],i=1..nops(xx)) );

quit;