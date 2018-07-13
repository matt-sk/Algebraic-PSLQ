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

	parametersString := readline(testfile):
	parameters := parse( parametersString, 'statement' );

	consts := parameters[consts];
	d := parameters[affix]:
	coeffDigits := parameters[digits]:

	# Set the precision based on the digits used for the coefficients.
	# Note that this is particular to PHASE-1 testing, and so can't be done by the gemeric stress-test-APSLQ.mpl implementation of SETUP()
	if coeffDigits = 1 then prec := 75 fi;
	if coeffDigits = 6 then prec := 175 fi;
	if (not assigned(prec)) then
		error "Coefficient digits should be 1 or 6. Received %1", coeffDigits;
	end if:

	SETUP( d, coeffDigits ):

	# Process the input file.
	GOODcount,BADcount,UNEXPECTEDcount,FAILcount := 0,0,0,0:
	for lineNum do 
		line := readline(testfile);
		if line = 0 then break end if;

		line := parse(line):		
		lineNum := line[id]:
		coefficients := line[coeffs]:
		N := nops(coefficients):

		# Calculate the linear combination
		x := expand( add( coefficients[k]*consts[k], k=1..N ) ):
		Indices := { seq(k,k=1..N) } minus { ListTools[SearchAll](0, coefficients) }: # Find the list indices for the non-zero coefficients
		xx := [ x, seq(consts[k], k in Indices) ]: # Produce a list of the non-zero coefficients.
		ans := [ -1, seq(coefficients[k], k in Indices) ]:

		calc := TEST( xx, d, prec );
		calc := map( sort, calc ); # Maple isn't entirely consistent with the order of sub-expressions when it outputs algebraic numbers. Hopefully this helps.

		RESULT := CHECK( calc, xx, ans, d, prec );

		extraOutput := EXTRAOUTPUT(RESULT,calc,xx,d,prec);

		# Increment the count
		cat(RESULT,count) := eval(cat(RESULT,count)) + 1;

		# Output the results.
		if RESULT = GOOD then
			fprintf( outfile, "%a,table([Result=%s,mult=%a%s])\n", lineNum, RESULT, -calc[1], extraOutput );
		else
			fprintf( outfile, "%a,table([Result=%s,calc=%a,CHK=%a%s])\n", lineNum, RESULT, calc, evalf[2](CHK), extraOutput );
		end if;

	end do:

	# Note that FAILcount is specific to the APSLQ file. Need some way to generalise this.
	printf("%s: %a good examples, %a unexpected examples, %a bad examples, %a fails.\n", OUTPUT, GOODcount, UNEXPECTEDcount, BADcount, FAILcount);

	fclose( testfile ):
	fclose( outfile ):

	TIDYUP():

catch:
	# Mimick the output of an error call before quitting with an error value of 1.
	str := "";
	if lastexception[1] <> 0 then str := sprintf( " (in %a)", lastexception[1] ) fi;
	printf( "%s: Error,%s %s\n", OUTPUT, str, StringTools[FormatMessage](lastexception[2..-1]) );
	`quit`(1):
end try:
