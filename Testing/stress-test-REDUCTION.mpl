# Read the definitions of the integer relation computing functions  (PSLQ_ and LLL_INTEGER_RELATION).
read "IntegerRelationFunctions.mpl":

# Define functions used by stress-test-common.mpl

# SETUP(): Function to run before processing to set up thigns that need setting up.
# Additionally, this function is responsible for raising any fatal errors that are contingent on the particulars of the test set.
SETUP := proc( D::integer, coeffDigits::posint )
	global INTEGER_RELATION_FUNCTION, LLL_INTEGER_RELATION, TEST, PRECHECK:

	# The default TEST is REDUCTION_TEST. We over-ride this below in the one case where that is not the case
	TEST := REDUCTION_TEST:

	if abs(D) in {0,1} then
		error "Pointless using REDUCTION method for a classical integer relation":
	elif INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION then
		if D < 0 then
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC(D): # This also covers the complex Classical case.

			# A different reduction is baked into the LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC function, so we don't need to do it in the TEST function.
			TEST := DIRECT_TEST: 
		else
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_REAL_CLASSICAL:
		end if:
	elif D < -1 then # (If we get here then we know we're not computing integer relations with LLL, so we must be using PSLQ)
		# Complex quadratic (non-classical) REDUCTION through PSLQ cases. 
		# We use the PRECHECK function  to transform candidate relations into the correct integer ring.
		PRECHECK := COMPLEX_QUADRATIC_PSLQ_PRECHECK_TRANSFORM:
	end if:	
end proc:

COMPLEX_QUADRATIC_PSLQ_PRECHECK_TRANSFORM := proc( calc, xx::~list(complexcons), D::integer, Precision::posint )::list;
	# NOTE: This proc is called from CHECK( ... ), and that function considers only candidates and candidate-specific data.
	# Any calculation-wide data is stripped off and saved before the call to CHECK( ... ). Consequently we will never see it here.
	# Consequently, we manipulate (and return) only candidates and candidate-specific data.
	local Relations, CHK, SqD, candidate, PrecheckData, clobber, sigma_2, idx, a, i, n, failcount:

	# Initialise PrecheckData.
	PrecheckData := NULL:

	if calc = FAIL then
		Relations := {}: # Pretty sure this can't happen, but we'll leave it in there anyway, just in case.
	else
		# There must be only one candidate integer relation because we only use this function if using PSLQ to calculate the REDUCTION method..
		CandidateRelation := calc[1][1]:
		CandidateData     := calc[1][2]:

		# We check to make sure that the elements of the integer relation are, in fact, quadratic integers from the correct sinple quadratic extension field.
		if type( CandidateRelation, list(SmplCplxQuadInt(D)) ) then # `and`( op(CHK) ) then
			# We already (and unexpectedly) have all complex quadratic integers. We simply return what we recieved, noting that no transform was applied.
			Relations := { [ CandidateRelation, [ op(CandidateData), (Transform)=None ] ] }:
		else
			# The integers in the candidate relation are from the wrong field (i.e., ℚ(i,√|d|)) and we need to try to transform them.

			# Precalculate SqD for simplicity in the later calculations.
			SqD := sqrt(abs(D)):

			# ==============
			# Clobber method
			# ==============
			clobber := xi -> coeff(Re(xi), SqD, 0) + coeff(Im(xi), SqD, 1)*I*SqD:
			candidate[1] := map( clobber, CandidateRelation ):

			# It is possible, but unlikely, that candidate[1] is currently full of 0's.
			# If this is the case, then the gaussian integer relation given by PSLQ must have been all imaginary only. 
			# Furthermore, CandidateRelation must consist of quadratic integers multiplied by I. 
			# We test for thsi and convert candidate[1] appropriately.
			if type( candidate[1], list(0) ) then candidate[1] = expand( I * CandidateRelation ): fi:

			# Format the candidate and candidate-specific data.
			candidate[1] := [ candidate[1], [ op(CandidateData), (Transform)=Clobber ] ]:

			# Update PrecheckData with information about 
			PrecheckData := ( PrecheckData, (`Clobber Candidates`) = 1 ):

			# ============
			# Sigma method
			# ============
			sigma_2 := xi-> coeff(Re(xi), SqD, 0) - coeff(Re(xi), SqD, 1)*SqD - coeff(Im(xi), SqD, 0)*I + coeff(Im(xi), SqD, 1)*I*SqD:

			# In essence, we hope that the value that turns an element into a quadratic integer by multiplication works for the whole vector.
			# We check every element, keeping all that work.
			idx, failcount := 2, 0:
			for i from 1 to nops(CandidateRelation) do
				a[i] := CandidateRelation[i]:
				if a[i] = 0 then next: fi: # The following processing is pointless if a[i] = 0.

				# Calcualte the next possible candidate relation.
				candidate[idx] := expand( sigma_2(a[i]) * CandidateRelation ):

				# Check to see if the relation contains only complex quadratic integers in ℚ(√d), and if so make sure we haven't already seen it.
				# Save the candidate if both of the above are true.
				if type( candidate[idx], list(SmplCplxQuadInt(D)) ) then # `and`( op(CHK) ) then 
					# We have the right types of integers. So we save the candidate (ignoring the possibility it may be a multiple of a previously transformed candidate)
					candidate[idx] := [ candidate[idx], [ op(CandidateData), (Transform)=Sigma, (`Element Index`)=i ] ]:
					idx := idx + 1:
				else 
					# Count the number of fails, for completeness.
					failcount := failcount + 1:
				end if:
			end do:

			# Clean up after ourselves. If this is defined at all, it cannot be a proper candidate.
			candidate[idx] := NULL:

			# ========================================
			# Combine the results from the two methods
			# ========================================

			# We might have some candidates from the sigma method, and we might not. It's easy to tell.
			PrecheckData := ( PrecheckData, (`Sigma Candidates`) = idx - 2, (`Sigma Fails`) = failcount, (`Original Candidate Elements`) = nops( CandidateRelation ) ):

			# Collect the new candidates (recall that candidate[idx] is NULL so it does not hurt to have it here)
			Relations := [ seq( candidate[k], k = 1..idx ) ]: # We make this a list becuase the order is potentially important.

		end if:
	end if:
	
	# Return the relation(s) we have found or modified.
	return Relations, [ PrecheckData ]:

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

# Run the tests.
read "stress-test-common.mpl";