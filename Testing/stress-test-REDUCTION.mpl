# Read the definitions of the integer relation computing functions  (PSLQ_ and LLL_INTEGER_RELATION).
read "IntegerRelationFunctions.mpl":

# Define functions used by stress-test-common.mpl

# SETUP(): Function to run before processing to set up thigns that need setting up.
# Additionally, this function is responsible for raising any fatal errors that are contingent on the particulars of the test set.
SETUP := proc( D::integer, coeffDigits::posint )
	global INTEGER_RELATION_FUNCTION, LLL_INTEGER_RELATION, TEST:

	# The default TEST is REDUCTION_TEST. We over-ride this below in the one case where that is not the case
	TEST := REDUCTION_TEST:

	if abs(D) in {0,1} then
		error "Pointless using REDUCTION method for a classical integer relation":
	elif INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION then
		if D < 0 then
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC(D):

			# A different reduction is baked into the LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC function, so we don't need to do it in the TEST function.
			TEST := DIRECT_TEST: 
		else
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_REAL_CLASSICAL:
		end if:
	end if:	
end proc:

# Function to perform the reduction
REDUCTION_TEST := proc( xx::~list(complexcons), D::integer, Precision::posint )
	local omega, xxE, CalcCandidates, CalcData, recover:

	# Set the precision. This is also set in INTEGER_RELATION_FUNCTION(), however we need it now so that our calculation of xxE is correct.
	Digits := Precision:

	# We extend the input list by taking each element, x,  and replacing it with x, omega*x
	omega := piecewise( D mod 4 = 1, (1+sqrt(D))/2, sqrt(D) ):
	xxE := map( x -> (x, omega*x), xx ):

	# Run the integer relation finding function
	CalcCandidates, CalcData := INTEGER_RELATION_FUNCTION(xxE, Precision):

	# Function to recover the algebraic integer relations from the PSLQ output.
	# Note that this function needs to preserve the format of [[candidateRelation], [candidateOutputData]] required to be returned.
	recover := candidate -> [ [ seq( expand(candidate[1][2*k-1]+omega*candidate[1][2*k]), k = 1 .. (nops(xxE)/2 ) ) ], candidate[2] ]:

	# We return either FAIL, or the set of Candidate relations, and pass through the output table data (CalcData).
	if CalcCandidates = FAIL then
		return FAIL, CalcData:
	else
		return map(recover, CalcCandidates), CalcData:
	end if:
end proc:

# Function to test.
DIRECT_TEST := proc( xx::~list(complexcons), D::integer, Precision::posint )
	return INTEGER_RELATION_FUNCTION( xx, Precision ):
end proc:

# Type declarations for the specific algebraic integers we need to test for.
`type/GaussInt` := proc(z)
	return ( type(Re(z), integer) and type(Im(z), integer) );
end proc:

`type/SmplCplxQuadInt` := proc(z, D::negint) 
	local a, b, c, discr, aIsInteger, bIsInteger, parityIsCorrect; 

	# Special Case (needed because sqrt(|D|) = 1 and we cannot find the coefficients of 1 using coeff())
	if D = -1 then return type(z, GaussInt); fi;

	# Calculate the coefficients of sqrt(abs(D))
	c[0], c[1] := coeff( z, sqrt(abs(D)), 0 ), coeff( z, sqrt(abs(D)), 1 );


	# Use those coefficients to find a and b such that z = a + b*sqrt(D))
	# Note that we cannot calculate coeff( •, sqrt(D) ) if D < 0. So we used the square root of |D| instead.
	# We account for that by taking the real part of c[1] and adding it (multiplied by sqrt(|D|) to a.
	a := c[0] + Re(c[1])*sqrt(abs(D));
	b := Im(c[1]);	# Now b will be everything multiplying I*sqrt(|D|).

	discr := D mod 4;

	if discr = 0 then 
		ERROR("Invalid simple complex quadratic extension: Q(sqrt(%1))", D);
	elif discr = 1 then 
		a,b := 2*(a,b); # Double a and b to account for half integers
		# We must have either both half integers, or both full integers. This is equivalent to identical parity after multiplication by 2.
		parityIsCorrect := (type(a,even) and type(b,even)) or (type(a,odd) and type(b,odd));
	else # discr = 2 or discr = 3
		parityIsCorrect := true; # parity is irrelevant in this case.
	fi;

	# Check that our a and b are integers.
	aIsInteger := type(a, integer); 
	bIsInteger := type(b, integer);

	return (aIsInteger and bIsInteger and parityIsCorrect);
end proc:

# POSTCHECK(): Function run after standard results checking is run.
# This function must return result in {GOOD, UNEXPECTED, BAD, FAIL} to report an outcome, and an output data list.
POSTCHECK := proc( result, relation, xx::~list(complexcons), D::integer, Precision::posint )
	local chk:

	# No post-checking needed for real test sets (or even for Gaussian integers, since REDUCTION is pointless in that case)
	if D >= -1 then return result, []: fi:

	# We only need to do additional checking if the result was not already a FAIL.
	if result = FAIL then return result, []: fi:

	# We check to make sure that the elements of the integer relation are, in fact, quadratic integers from the correct sinple quadratic extension field.
	chk := map( type, relation, SmplCplxQuadInt(D) ):

	if `and`( op(chk) ) then
		# No change to result. Return it with an empty list of output table data.
		return result, []: # Result should be GOOD, but whatever it is, it's preserved.
	else
		# Change the result to FAIL, which we return along with the original result saved as an entry in the output table data.
		return FAIL, [ (OriginalResult) = result ]:
	end if:
end proc:

# Run the tests.
read "stress-test-common.mpl";