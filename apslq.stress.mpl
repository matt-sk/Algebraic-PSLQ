interface(quiet=true):
read "APSLQ.support.mpl":

test1 := fopen("StressExamples/test1.txt",READ):
test2 := fopen("StressExamples/test2.txt",READ):
test3 := fopen("StressExamples/test3.txt",READ):
test4 := fopen("StressExamples/test4.txt",READ):
testA := fopen("StressExamples/testA.txt",READ):

#while not FileTools[AtEndOfFile](test1) do
#    parse( FileTools[Text][ReadLine]( test1 ) );
#end do:

#parse( FileTools[Text][ReadLine]( test2 ) );
#parse( FileTools[Text][ReadLine]( test3 ) );
#parse( FileTools[Text][ReadLine]( test4 ) );

Broken;
xx, p, Digits := op( parse( FileTools[Text][ReadLine]( test2 ) ) );
xx := evalf(xx);    
yy :=  parse( FileTools[Text][ReadLine]( testA ) );

#Working
#Digits := 50;
#p  := -1;
#xx := evalf([Pi, exp(1), -exp(1)*(2-3*aa[1]), -Pi*(1+2*aa[1]) ] );

#Working
#Digits := 50;
#p     := 2;
#alpha := (-412 - 5*aa[1] ) * Pi + (7 - 223*aa[1])*exp(1) + (-523 - 8*aa[1] )*ln(2);
#xx    := [alpha, Pi, exp(1), ln(2) ]:
#xx    := evalf( xx );

APSLQ[SetAffix]( p );
APSLQ[Info]();
APSLQ[APSLQ]( xx, iterations=infinity, threshold=1/10^(Digits-5) );
#yy;

fclose(test1,test2,test3,test4):

quit;