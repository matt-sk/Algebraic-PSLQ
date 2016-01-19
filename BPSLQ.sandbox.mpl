interface(quiet=true):
read "BPSLQ.mpl":

Digits := 50:
alpha[1] := evalf( sqrt(2)*I, 50 );

xx := [ alpha[1], 1, evalf(Pi), ln(2.)]:

lprint("BPSLQ");
ans   := BPSLQ( xx, iterations=500, threshold=1/10^(Digits-5), digits=Digits );
abs( add( xx[i]*ans[i], i=1..nops(xx) ) );


lprint("IntegerRelations");
ans  := IntegerRelations[PSLQ]( xx );
abs( add( xx[i]*ans[i], i=1..nops(xx) ) );

quit;







Digits := 50;

#alpha := sqrt(3.) - sqrt(2.):
#alpha := evalf( Re( sqrt(2) ), 100 );
alpha := 8.5557740294193677145942152523917120406963393361912326584326092225892073004511968596795229586699088861323020971088473562289297701621336866915814018227972660826234785:

#alpha := 1+ln(3.)*I:
xx    := [ alpha*(1+I), 1, evalf(Pi), ln(2.)]:
xx    := evalf( xx ):

#f     := PolynomialTools[MinimalPolynomial]( alpha, x, 10);
#xx    := [ seq(alpha^i, i=0..degree(f,x)) ]:

ans   := BPSLQ( xx, iterations=infinity, threshold=1/10^(Digits-5), digits=Digits ):

add( xx[i]*ans[i], i=1..nops(ans));
abs( add( xx[i]*ans[i], i=1..nops(ans)) );

quit;

