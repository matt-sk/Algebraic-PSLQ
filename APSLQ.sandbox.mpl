interface(quiet=true):
read "APSLQ.support.mpl":

Digits := 100:

pp := [2]:

APSLQ[SetAffix]( op(pp) );
APSLQ[Info]();


alpha := (-412 - 5*aa[1])*Pi + (7 - 223*aa[1])*exp(1) + (-523 - 8*aa[1])*ln(2);
alpha := eval( alpha, [seq(aa[i] = sqrt(pp[i]), i=1..nops(pp))]  );
alpha := evalf( alpha );

xx := [alpha, Pi, exp(1), ln(2) ]:
xx := evalf( xx ):

ans   := APSLQ[APSLQ]( xx, iterations=10, threshold=1/10^(Digits-5), digits=Digits );







quit;

pp := [-1]:

alpha[1] := 8.5557740294193677145942152523917120406963393361912326584326092225892073004511968596795229586699088861323020971088473562289297701621336866915814018227972660826234785 + 19.5245199789778207252709649000355636736293248679379812876485209200681378501683637447418153530412133861344645065764304799255945701193060988563269844700085446896322031*aa[1]:
alpha[2] := 240.2580715512005850377991641860749049037349215083857742661467434047260038067178950809318221943327582161743869784010182847623831977533217181552096871784099275510000929 - 197.7231299819772360738201009482325219970251881102166481443122240054056135688592625739072692028291163278533468709595297851879697973293924262946187211177789954254215274*aa[1]:
#alpha[2] := evalf( Re( sqrt(2) ), 100 ):

xx := [ alpha[1], 1, evalf(Pi), ln(2.)]:
#xx := [ Pi, exp(1), -exp(1)*(2 - 3*aa[1] ) - Pi*(1 + 2*aa[1] ) ];

lprint("APSLQ");

#CodeTools[Profiling][Profile]( APSLQ ):
ans   := APSLQ( xx, iterations=1000, threshold=1/10^(Digits-5), digits=Digits );
#CodeTools[Profiling][PrintProfiles]( APSLQ );


quit;






Reduce( add( xx[i]*ans[i], i=1..nops(xx) ), 1):
evalf( aabs(Reduce(add( xx[i]*ans[i], i=1..nops(xx) ))), 100 );


lprint("MAPLE");
xx   := subs(aa[1]=sqrt(pp[1]),xx):
ans  := IntegerRelations[PSLQ]( xx );
evalf( add( xx[i]*ans[i], i=1..nops(xx) ) );
abs( % );

quit;