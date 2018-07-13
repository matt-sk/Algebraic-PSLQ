# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Preprocessing setup of I/O file names.                                                                        =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =- 
$ifdef __INPUT
	INPUT := __INPUT:
$endif

$ifdef __OUTPUT
	OUTPUT := __OUTPUT:
$endif

$ifdef __INPUT_LENGTH
	INPUT_LENGTH := __INPUT_LENGTH:
$endif

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Callback function declaration.                                                                                =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= These are function hooks that can be over-ridden by the scripts using this common framework                   =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# The TEST() function needs to be set by the specific test script.
# Note that this must be a function so the error is raised inside the try-catch block below.
if not assigned( TEST ) then
	TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
		error "TEST Function needs to be Redefined";
	end proc;
end if:

# The remaining two functions are optional. If not set by the test script then the following definitions are used.

# SETUP(): Function to run before processing to set up thigns that need setting up.
if not assigned( SETUP ) then
	SETUP := proc( D::integer, coeffDigits::posint )
	end proc:
end if:

# PRECHECK(): Function run before standard results checking is run.
# This function must return GOOD, BAD, FAIL to report an outcome, or CONTINUE to allow further checking.
if not assigned( PRECHECK ) then
	PRECHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		return CONTINUE;
	end proc:
end if:

# EXTRAOUTPUT(): Function run after standard outputting is performed, but before newline is output.
# result will be one of GOOD, BAD, FAIL, or UNEXPECTED
if not assigned( EXTRAOUTPUT ) then
	EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::string;
		return "";
	end proc:
end if:

# TIDYUP() : Function to run after all processing is complete.
if not assigned( TIDYUP ) then
	TIDYUP := proc()
	end proc:
end if:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Main Processing                                                                                               =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# We enclose everythign in a try/catch block to detect errors and exit with a fail code for Make to detect.
try 
	# I/O file Setup
	if not assigned(INPUT) then
		error "No input file";
	else
		testfile := fopen( INPUT, READ, TEXT );
	end if:

	if (not assigned(OUTPUT)) or (OUTPUT=default) then
		outfile := fopen( "/dev/null", WRITE, TEXT );
	else
		outfile := fopen( OUTPUT, WRITE, TEXT );
	end if:

	if (not assigned(INPUT_LENGTH)) or (INPUT_LENGTH=default) then
		INPUT_LENGTH := long:
	elif (not INPUT_LENGTH in {short,long}) then
		error "INPUT_LENGTH should be 'short' or 'long'. Received %1", INPUT_LENGTH:
	end if:

	parametersString := readline(testfile):
	parameters := parse( parametersString, 'statement' );

	consts := parameters[consts];
	d := parameters[affix]:
	coeffDigits := parameters[digits]:

	SETUP( d, coeffDigits ):

	# Process the input file.
	GOODcount,BADcount,UNEXPECTEDcount := 0,0,0:
	while true do 
		line := readline(testfile);
		if line = 0 then break end if;

		line := parse(line):		
		lineNum := line[id]:
		coefficients := line[coeffs]:
		N := nops(coefficients):

		# Calculate the linear combination
		x := expand( add( coefficients[k]*consts[k], k=1..N ) ):
		if INPUT_LENGTH = short then
			Indices := { seq(k,k=1..N) } minus { ListTools[SearchAll](0, coefficients) }:
			xx := [ x, seq(consts[k], k in Indices) ]:
			ans := [ -1, seq(coefficients[k], k in Indices) ]:
		else
			xx := [ x, op(consts) ]:
			ans := [ -1, op(coefficients) ]:
		end if:

		# We need some way to choose between all constants in the vector, and only the required constants.

		basePrecision := coeffDigits * [ (nops(ans)-numboccur(0, ans)), nops(coefficients)+1 ]:

		# We perform a binary search on 
		minPrec,maxPrec := 0,500:

		# We start by checking the max precision case.
		precision := maxPrec:
		calc := TEST( xx, d, precision ):
		RESULT := CHECK( calc, xx, ans, d, precision ):
		extraOutput := EXTRAOUTPUT(RESULT,calc,xx,d,precision);

		if RESULT = GOOD then
			# We only perform the binary search if our max precision produced a GOOD result.
			while maxPrec - minPrec > 1 do
				precision := floor( minPrec + (maxPrec - minPrec) / 2 ):
				calc := TEST( xx, d, precision ):
				RESULT := CHECK( calc, xx, ans, d, precision ):

				if RESULT = GOOD then
					maxPrec := precision;
					extraOutput := EXTRAOUTPUT(RESULT,calc,xx,d,precision);
				else
					minPrec := precision;
				end if:
			end do:

			# We know that the result for precision=maxPrec is GOOD.
			# However the variables from the most recent loop execution may not reflect this.
			RESULT := GOOD:
			precision := maxPrec;
		end if:

		# Output the results.
		fprintf( outfile, "%a,table([Result=%s,Precision=%a,BasePrecision=%a%s])\n", lineNum, RESULT, precision, basePrecision, extraOutput ):
	end do:

	# Note that FAILcount is specific to the APSLQ file. Need some way to generalise this.
	printf( "%s: complete.\n", OUTPUT );

	fclose( testfile ):
	fclose( outfile ):

	TIDYUP():

catch:
	# Mimick the output of an error call before quitting with an error value of 1.
	str := "";
	if lastexception[1] <> 0 then str := sprintf( " (in %s)", lastexception[1] ) fi;
	printf( "%s: Error,%s %s\n", OUTPUT, str, StringTools[FormatMessage](lastexception[2..-1]) );
	`quit`(1):
end try:
