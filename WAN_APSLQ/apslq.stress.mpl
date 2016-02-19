interface(quiet=true):
read "APSLQ.support.mpl":
read "APSLQ.mpl":

test1 := fopen("../StressExamples/test1.txt",READ):
testA := fopen("../StressExamples/testA.txt",READ):

CodeTools[Profiling][Profile](APSLQ):

N := 10:
for i from 1 to N do 
#    FileTools[Text][ReadLine]( test1 );
#    FileTools[Text][ReadLine]( testA );
    
    #Read input
    xx, p, Digits := op( parse( FileTools[Text][ReadLine]( test1 ) ) ):
    yy  :=  parse( FileTools[Text][ReadLine]( testA ) );
    
    printf("\nTest Example %a for D=%a\n",i,-p);
    
    #How close actual answer is
    lprint( xx[1] + evalf( add( x, x in zip(`*`, xx[2..-1], yy) ) ) );
    
    zz := APSLQ( xx, abs(p), digits=trunc(Digits*1.25), iterations=200, threshold=10^( -trunc(.75*Digits) ) );
    
    #How close our answer is
    if zz = FAIL then
        lprint(FAIL);
    else
        lprint( evalf( add( x, x in zip(`*`, xx, zz) ) ) );
    end if;

end do:

CodeTools[Profiling][PrintProfiles](APSLQ);


stop;