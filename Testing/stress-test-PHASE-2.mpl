# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Main Processing                                                                                               =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# We enclose everythign in a try/catch block to detect errors and exit with a fail code for Make to detect.
try 
	# I/O file Setup
	if not assigned(INPUT) then
		error "No input file":
	else
		testfile := fopen( INPUT, READ, TEXT ):
	end if:

	if (not assigned(OUTPUT)) or (OUTPUT=default) then
		outfile := fopen( "/dev/null", WRITE, TEXT ):
	else
		outfile := fopen( OUTPUT, WRITE, TEXT ):
	end if:

	if (not assigned(INPUT_LENGTH)) or (INPUT_LENGTH=default) then
		INPUT_LENGTH := long:
	elif (not INPUT_LENGTH in {short,long}) then
		error "INPUT_LENGTH should be 'short' or 'long'. Received %1", INPUT_LENGTH:
	end if:

	parametersString := readline(testfile):
	parameters := parse( parametersString, 'statement' ):

	consts := parameters[consts]:
	d := parameters[affix]:
	coeffDigits := parameters[digits]:

	SETUP( d, coeffDigits ):

	# Process the input file.
	GOODcount,BADcount,UNEXPECTEDcount := 0,0,0:
	while true do 
		line := readline(testfile):
		if line = 0 then break end if:

		line := parse(line):		
		lineNum := line[id]:
		coefficients := line[coeffs]:
		N := nops(coefficients):

		# Calculate the linear combination
		x := expand( add( coefficients[k]*consts[k], k=1..N ) ):

		# Divide the indices into those matching the constants that are part of the relation, and those that are unused.
		(UnusedIndices, Indices) := selectremove( k->is(coefficients[k]=0), [seq(k,k=1..N)] ):
		
		xx := [ x, seq(consts[k], k in Indices) ]:
		ans := [ -1, seq(coefficients[k], k in Indices) ]:

		# For long input we attempt to double the input vector size, padding it with unneeded constants.
		# However, it's possible there aren't enough remaining constants, in which case we just use everythig.
		if INPUT_LENGTH = long then
			numIndices := min( nops(Indices), nops(UnusedIndices) ): # Account for the possibility of not enough unused constants.
			xx := [ op(xx), seq(consts[k], k in UnusedIndices[1..numIndices]) ]:
			ans := [ op(ans), seq( 0, k = 1..numIndices ) ]:
		end if:

		# Base precision is the maximum number of digits in each integer coefficient multiplied by the number of integers in the relation.
		# It is unclear whether algebraic integers (including gaussian integers) count as having twice as many digits or not (e.g., is 1+2I 
		# a 1-digit or 2-digit gaussian integer?). We use the formula as stated in the literature; it can be doubled later if necessary.
		basePrecision := coeffDigits * nops(ans):

		# Idea: count the number of /actual/ digits in the answer, and use that as a measure, too?

		# Set up the precision bounds for the binary search. (for reference: we know from the JBCC paper testing (which was short-input) 
		# that 75 decimal digits is (more than) enough for single digit integers, and 175 for 6-digit integers.)

		# Start at 1 decimal digit of precision and double the precision until we get a GOOD result (or the precision is too large).
		precision := 1/2:
		RESULT := NULL:
		while RESULT <> GOOD and precision <= 500 do
			precision := 2*precision:
			calc := TEST( xx, d, precision ):
			RESULT,rel := CHECK( calc, xx, ans, d, precision ):
		end do:

		# Get the extra output from the most recent test. Even if the result is not GOOD, as this might still be the final result.
		extraOutput := EXTRAOUTPUT(RESULT,rel,xx,d,precision):

		# We only perform the binary search if our max precision produced a GOOD result.
		if RESULT = GOOD then
			minPrec, maxPrec := max( precision/2, 1 ), precision:
			while maxPrec - minPrec > 1 do
				precision := floor( minPrec + (maxPrec - minPrec) / 2 ):
				calc := TEST( xx, d, precision ):
				RESULT,rel := CHECK( calc, xx, ans, d, precision ):
				if RESULT = GOOD then
					maxPrec := precision:
					extraOutput := EXTRAOUTPUT(RESULT,calc,xx,d,precision):
				else
					minPrec := precision:
				end if:
			end do:

			# We know that the result for precision=maxPrec must be GOOD.
			# However the precision variable from the most recent loop execution may have a different value; we set it appropriately.
			RESULT := GOOD:
			precision := maxPrec:
		end if:

		# Sanity Check: see what result we get at one higher precision (hopefully it is the same result).
		ChkCalc := TEST( xx, d, precision+1 ):
		ChkResult,ChkRelation := CHECK( ChkCalc, xx, ans, d, precision+1 ):

		# Output the results.
		fprintf( outfile, "%a,table([Result=%s,Precision=%a,BasePrecision=%a,Check=%a%s])\n", lineNum, RESULT, precision, basePrecision, ChkResult, extraOutput ):
	end do:

	# Note that FAILcount is specific to the APSLQ file. Need some way to generalise this.
	printf( "%s: complete.\n", OUTPUT ):

	fclose( testfile ):
	fclose( outfile ):

	TIDYUP():

catch:
	# Mimick the output of an error call before quitting with an error value of 1.
	str := "":
	if lastexception[1] <> 0 then str := sprintf( " (in %s)", lastexception[1] ) fi:
	printf( "%s: Error,%s %s\n", OUTPUT, str, StringTools[FormatMessage](lastexception[2..-1]) ):
	`quit`(1):
end try:
