# Preprocessor conversion from defines to variables.
$ifdef __INTEGER_RELATION_FUNCTION
	INTEGER_RELATION_FUNCTION := __INTEGER_RELATION_FUNCTION:
$endif

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
	local xx, M, maxXX, K, k, n, calc, evaluate, rows, Id, V, epsilon:
	global LLL_Num_Attempts, LLL_Num_Candidates, FAILinfo:

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
	K := Digits - ilog10( maxXX ) + 1: # (Note: if x has d digits then log10(x)=d-1)

	# Initialise rows so the loop works correctly on the first iteration.
	rows := {}:

	# We do not know ahead of time what size N must be.
	# Furthermore, we know experimentally that due to numeric constraints, N can be too large in practice.

	# We start with N = 10^K and decrement the power of 10 until we get to N=1 (10^0).
	# For each value of N we try to find an integer realtion. If we find anything at all, 
	# we collect all the candidate relations into a set, and stop processing.
	for k from K to 0 by -1 while rows = {} do
		try
			# Calculate N*xx
			V := (10^k)*xx:
			
			# Sanity check. Make sure that there are no 0's in V (which might happen if we're not computing to enough digits).
			if 0 in { entries(V, nolist) } then error "V contains 0" fi: # Force the catch: clause, below
			
			# Try to find integer relations using LLL (making sure we're not using integer arithmetic)
			calc := LLL( <Id|V>, :-integer=false ):

			# Find any row which has final entry less than 1 (this may have an linear relation)
			# Note: ideally we're looking for 0 in the last entry, but searching for anything less than 1 seems, experimentally, to work fine.
			epsilon := 1; 
			rows := { seq(i,i=1..n) }:
			rows := select( r -> abs(calc[r][-1]) < epsilon, rows ): # If using integers, then only 0 will be selected for.
			rows := map( r -> convert(calc[r][1..-2], list), rows ): # Repace the row indices with the actual row, as a list.
		catch:
			# If there's an error then manually set rows to be the empty set.
			rows := {}:
		end try:
	end do:

	# Record number of LLL runs to find a relation at all, and number of candidate relations found
	LLL_Num_Attempts := K - k: # k will be decremented one extra time by the loop, but this is gives the correct count since we start at k=K.
	LLL_Num_Candidates := numelems( rows ):

	# If we get to this point, then either we found posisble integer relations (for some value of k)
	# or we got to k=1 without finding any posisble relation.
	if rows = {} then
		FAILinfo := "No candidate relations found for this precision":
		return FAIL:
	else
		return map2( map, trunc, rows ): # Make sure each eleement of each candidate relation is an integer.
	end if:
end proc:

# Function to calculate an integer relation using PSLQ. Saves the time taken.
PSLQ_INTEGER_RELATION := proc( xx::~Vector[column](complexcons), Precision::posint )
	uses IntegerRelations:
	local calc:
	global FAILinfo:

	# Make sure FAILinfo is an empty string so that EXTRAOUTPUT functions which expect it may use of it without error.
	FAILinfo := "":

	# Set precision and run PSLQ to find a candidate integer relation.
	Digits := Precision:
	calc := PSLQ( xx ):

	# Convert the candidate integer relation to a list, and return that list as the only element of a singleton set.
	return { convert( calc, list ) }:
end proc:
