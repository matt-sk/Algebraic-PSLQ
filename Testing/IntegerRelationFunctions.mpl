# Determine whether or not we are using PSLQ or LLL.
if (not assigned(INTEGER_RELATION_FUNCTION)) then
	WARNING( "INTEGER_RELATION_FUNCTION not defined. Defaulting to INTEGER_RELATION_FUNCTION=PSLQ.");
	INTEGER_RELATION_FUNCTION := PSLQ_INTEGER_RELATION
elif not INTEGER_RELATION_FUNCTION in {PSLQ,LLL} then
	WARNING( "INTEGER_RELATION_FUNCTION is neither PSLQ, nor LLL. Defaulting to INTEGER_RELATION_FUNCTION=PSLQ.");
	INTEGER_RELATION_FUNCTION := PSLQ_INTEGER_RELATION
else
	INTEGER_RELATION_FUNCTION := piecewise( is(INTEGER_RELATION_FUNCTION = PSLQ), PSLQ_INTEGER_RELATION, LLL_INTEGER_RELATION ):
fi;

# Function to calculate an integer relation using LLL. Saves the time taken.
LLL_INTEGER_RELATION := proc( x::~Vector[column](realcons), Precision::posint )
	uses IntegerRelations, LinearAlgebra:
	local xx, M, maxXX, K, k, n, calc, evaluate, rows, Id, epsilon:

	# Calculate the length of the input vector.
	n := Dimension( x ):

	# Set precision
	Digits := Precision:

	# We must create the augmented matrix <I | N*xx> for a sufficiently large value N
	Id := IdentityMatrix(n):
	xx := map( evalf, x ):

	# We want to make sure when we multiply xx by N=10^k that we don't end up with an integer containing more digits than our precision.
	# We do this by finding the number of digits in the integer part of the element of xx with the largest absolute value.
	maxXX := max( map(abs, xx) ):
	K := Digits - ( ilog10(maxXX) + 1 ): # (Note: if x has integer part with d digits then log10(x)=d-1)
# WARNING: K is sometiems negative (presumably if maxXX has a large integer part and we're computing to low precision). Need to think this through. 
# Maybe take maximum with 0.
# Or maybe just ignore it, since the loop below will immediately fail and we'll just try with larger precision later.

	# Initialise rows so the loop works correctly on the first iteration.
	rows := {}:

	# We do not know ahead of time what size N must be.
	# Furthermore, we know experimentally that due to numeric constraints, N can be too large in practice.

	# We start with N = 10^K and decrement the power of 10 until we get to N=1 (10^0).
	# For each value of N we try to find an integer realtion. If we find anything at all, 
	# we collect all the candidate relations into a set, and stop processing.
	M := < Id | (10^K)*xx >:
	for k from K to 0 by -1 while rows = {} do
		try
			# Sanity check. Make sure that there are no 0's in the last column (which might happen if we're not computing to enough digits).
			if 0 in { entries(Column(M,n+1), nolist) } then error "(n+1)th column contains 0" fi: # Force the catch: clause, below
			
			# Try to find integer relations using LLL (making sure we're not using integer arithmetic)
			calc := LLL( M, :-integer=false ):
			forget( LLL ):	# Needed to clear the remember table so that LLL calculates the next iteration properly. 
							# (Not 100% sure why this is necessary, but it is something to do with the inplace ColumnOperation below).

			# Find any row which has final entry less than 1 (this may have an linear relation)
			# Note: ideally we're looking for 0 in the last entry, but searching for anything less than 1 seems, experimentally, to work fine.
			epsilon := 1; 
			rows := { seq(i,i=1..n) }:
			rows := select( r -> abs(calc[r][-1]) < epsilon, rows ): # Remove the index of any row whose final element is not less than epsilon.
			rows := map( r -> convert(calc[r][1..-2], list), rows ): # Repace the row indices with the actual row, as a list.
		catch:
			# If there's an error then manually set rows to be the empty set.
			rows := {}:
		finally:
			# Efficiently calculate M := < Id | (10^(k-1))*xx ready for the next round.
			# Using the inplace ColumnOperation should save memory usage (compared to M:=<Id|(10^(k-1))*xx)
			ColumnOperation( M, n+1, 1/10, inplace ):
		end try:
	end do:

	# If we get to this point, then either we found posisble integer relations (for some value of k)
	# or we got to k=1 without finding any posisble relation.
	# We return the appropirate result, and 
	if rows = {} then
		# Return FAIL, and an appropriate output data table containing FAIL_info and appropriate LLL computation info.
		return FAIL, [ (FAIL_info) = "No candidate relations found for this precision", (LLL_attempts) = K - k ]:
	else
		# Truncate each element of each candidate relation to ensure it is an integer.
		# We return the result of this, along with the  output table data for this LLL integer relation computation.
		return map2( map, trunc, rows ), [ (`LLL InitialN`) = evalf[1](10^K), (`LLL FinalN`) = evalf[1](10^(k+1)), (`LLL Attempts`) = K - k, (`LLL CandidateRelations`) = numelems(rows) ]: 
	end if:
end proc:

# Function to calculate an integer relation using PSLQ. Saves the time taken.
PSLQ_INTEGER_RELATION := proc( xx::~list(complexcons), Precision::posint )
	uses IntegerRelations:
	local calc:

	# Set precision and run PSLQ to find a candidate integer relation.
	Digits := Precision:
	calc := PSLQ( xx ):

	# Return the calcualted relation as the only element of a singleton set, and an empty list of output data.
	return { calc }, []:
end proc:
