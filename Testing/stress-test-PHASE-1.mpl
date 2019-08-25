# Set the precision based on the digits used for the coefficients.

# SETUP will definitely be assigned: either by stress-test-common.mpl, or maybe earlier.
OLDSETUP := eval( SETUP ): # There should probably be a better way to do this. Not sure what it is right now.

SETUP := proc( D::integer, coeffDigits::posint )
	global prec:

	# Run the original setup
	OLDSETUP( D, coeffDigits ):

	# Set the precision bsed on the number of digits.
	if coeffDigits = 1 then prec := 75 fi;
	if coeffDigits = 6 then prec := 175 fi;
	if (not assigned(prec)) then
		error "Coefficient digits should be 1 or 6. Received %1", coeffDigits;
	end if:
end proc:

# Function to process a testfile input line. (Called by stress-test-common.mpl)
PROCESS_TEST_PROBLEM := proc( line::table )
	global prec:
	local coefficients, N, x, Indices, xx, ans, CalcData:
	
	coefficients := line[coeffs]:
	N := nops(coefficients):

	# Calculate the linear combination
	x := expand( add( coefficients[k]*consts[k], k=1..N ) ):
	Indices := { seq(k,k=1..N) } minus { ListTools[SearchAll](0, coefficients) }: # Find the list indices for the non-zero coefficients
	xx := [ x, seq(consts[k], k in Indices) ]: # Produce a list of the non-zero coefficients.
	ans := [ -1, seq(coefficients[k], k in Indices) ]:

	# Run CALCULATE_TEST_PROBLEM and pass the output straight back to the caller of this procedure.
	return CALCULATE_TEST_PROBLEM( xx, ans, prec ):
end proc:
