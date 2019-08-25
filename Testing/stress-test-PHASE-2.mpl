# Extra input processing. Check INPUT_LENGTH.
try
	if (INPUT_LENGTH=default) then
		INPUT_LENGTH := long:
	elif (not assigned(INPUT_LENGTH)) then
		WARNING( "INPUT_LENGH not given. Defaulting to INPUT_LENGTH=long."):
		INPUT_LENGTH := long:
	elif (not INPUT_LENGTH in {short,long}) then
		error "INPUT_LENGTH should be 'short' or 'long'. Received %1", INPUT_LENGTH:
	end if:

catch:
	TerminateAndCatchFire( 2 ):

end try:

# Function to process a testfile input line. (Called by stress-test-common.mpl)
PROCESS_TEST_PROBLEM := proc( line::table )
	local coefficients, N, x, UnusedIndices, Indices, xx, ans, chkResult, TestData, SaveData:
	local result, numIndices, basePrecision, precision, minPrec, maxPrec:
	global coeffDigits:

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

	# Set up the precision bounds for the binary search. (for reference: we know from the JBCC paper testing (which was short-input) 
	# that 75 decimal digits is (more than) enough for single digit integers, and 175 for 6-digit integers.)

	# Start at 1 decimal digit of precision and double the precision until we get a GOOD result (or the precision is too large).
	precision := 1/2:
	while result <> GOOD and precision <= 500 do
		precision := 2*precision:
		result, TestData := CALCULATE_TEST_PROBLEM( xx, ans, precision ):
	end do:

	# Get the extra output from the most recent test. Even if the result is not GOOD, as this might still be the final result.
	SaveData := TestData:

	# We only perform the binary search if our max precision produced a GOOD result.
	if result = GOOD then
		minPrec, maxPrec := max( precision/2, 1 ), precision:
		while maxPrec - minPrec > 1 do
			precision := floor( minPrec + (maxPrec - minPrec) / 2 ):
			result, TestData := CALCULATE_TEST_PROBLEM( xx, ans, precision ):
			if result = GOOD then
				maxPrec := precision:
				SaveData := TestData:
			else
				minPrec := precision:
			end if:
		end do:

		# ==============================
		# WHAT ABOUT UNEXPECTED RESULTS?
		# ==============================

		# We know that the result for precision=maxPrec must be GOOD. (We don't enter this code block if we can't guarantee a known GOOD result).
		# However the result and precision variables from the most recent loop execution may not represent this; we set them appropriately.
		result, precision := GOOD, maxPrec:
	end if:

	# Sanity Check: see what result we get at one higher precision (hopefully it is the same result).
	chkResult, TestData := CALCULATE_TEST_PROBLEM( xx, ans, precision+1 ):

	# Return the result along with amalgamated output table data for this run. 
	# (recall that SaveData has theoutput data from the most recently GOOD-producing CALCULATE_TEST_PROBLEM() execution.)
	return result, [ (TheoreticalMinPrecision) = basePrecision, op(SaveData), (PrecisionSanityCheck) = chkResult ]:
end proc:
