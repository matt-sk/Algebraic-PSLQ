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

# We define utility functions for LLL. It is up to the SETUP() function to define LLL_CREATE_LATTICE_MATRIX, LLL_UPDATE_LATTICE_MATRIX, and LLL_FORMAT_CANDIDATE appropriately.



LLL_INTEGER_RELATION_REAL := proc( x::~Vector[column](realcons), Precision::posint )

	uses LinearAlgebra:
	
	local M, n := Dimension( x ), discriminant := n+1:

	# Set up utility functions

	# Determine if a row is a candidate.
	global LLL_IS_CANDIDATE := subs( [ _d = discriminant ], 
		proc( row::Vector(realcons), epsilon )
			return is( abs(row[_d]) < epsilon ):
		end proc
	):

	# The candidates must be formatted in the form [[candidateRelation], candidateOutputData].
	# Additionally we truncate each element of each candidate relation to ensure it is an integer.
	global LLL_FORMAT_CANDIDATE := subs( [ _n = n, _d = discriminant ],
		proc( row::Vector(realcons) )
			return [ [seq( trunc(row[k]), k = 1.._n )], [`LLL Discriminant` = row[_d]] ]:
		end proc
	):

	# Efficiently update the matrix M by reducing the discriminant by a factor of 10.
	# Using the inplace ColumnOperation should save memory usage (compared to directly recalculating).
	global LLL_UPDATE_LATTICE_MATRIX := subs( [ _d = discriminant ],
		proc( M::Matrix(realcons) ) # Matrices are pass by reference, so inplace operations on M will modify the original matrix
			LinearAlgebra[ColumnOperation]( M, _d, 1/10, inplace ):
		end proc
	):

	Digits := Precision:

	# Create the matrix represneting the lattice.
	M := < IdentityMatrix( n ) | 10^(Precision-1)*map( evalf, x ) >:

	# Run the worker function
	return DO_LLL_INTEGER_RELATION( M, Precision-1 ):

end proc:

LLL_INTEGER_RELATION_COMPLEX := proc( x::~Vector[column](complexcons), Precision::posint )
	uses LinearAlgebra:
	
	local M, n := Dimension( x ), discriminant1 := n + 1, discriminant2 := 2*n + 2:

	# Set up utility functions.

	# Determine if a row is a candidate.
	global LLL_IS_CANDIDATE := subs( [ _d1 = discriminant1, _d2 = discriminant2 ],
		proc( row::Vector(realcons), epsilon )
			return is( abs(row[_d1]) < epsilon ) and is( abs(row[_d2]) < epsilon ):
		end proc 
	):

	# The candidates must be formatted in the form [[candidateRelation], candidateOutputData].
	# Additionally we truncate each element of each candidate relation to ensure it is an integer.
	global LLL_FORMAT_CANDIDATE := subs( [ _n = n, _d1 = discriminant1, _d2 = discriminant2 ], 
		proc( row::Vector(realcons) )
			return [ [seq( trunc(row[k] + I*row[k+_d1]), k = 1.._n)], [`LLL Discriminant` = [row[_d1], row[_d2]]] ]:
		end proc
	):

	# Efficiently update the matrix M by reducing the discriminants by a factor of 10.
	# Using the inplace ColumnOperation should save memory usage (compared to directly recalculating).
	global LLL_UPDATE_LATTICE_MATRIX := subs( [ _d1 = discriminant1, _d2 = discriminant2 ],
		proc( M::Matrix(realcons) ) # Matrices are pass by reference, so inplace operations on M will modify the original matrix
			LinearAlgebra[ColumnOperation]( M, _d1, 1/10, inplace ):
			LinearAlgebra[ColumnOperation]( M, _d2, 1/10, inplace ):
		end proc
	):

	Digits := Precision:

	# Create the matrix represneting the lattice.
	M := < IdentityMatrix(n) | 10^(Precision-1)*map( evalf, x ) >:

	# Convert the lattice into the equivalent real lattice for LLL.
	M := < Re(M), -Im(M) | Im(M), Re(M) >:

	# Run the worker function
	return DO_LLL_INTEGER_RELATION( M, Precision-1 ):

end proc:

# Function to calculate an integer relation using LLL. Saves the time taken.
DO_LLL_INTEGER_RELATION := proc( M::Matrix(realcons), K::nonnegint )

	uses IntegerRelations, LinearAlgebra:

	local xx, maxXX, k, n, calc, evaluate, candidates, Id, epsilon, rowIndices:

	# Initialise candidates so the loop works correctly on the first iteration.
	candidates := {}:
	rowIndices := { seq(i,i=1..RowDimension(M)) }:

	# We do not know ahead of time what size N must be.
	# Furthermore, we know experimentally that due to numeric constraints, N can be too large in practice.

	# We start with N = 10^K and decrement the power of 10 until we get to N=1 (10^0).
	# For each value of N we try to find an integer realtion. If we find anything at all, 
	# we collect all the candidate relations into a set, and stop processing.

	for k from K to 0 by -1 while candidates = {} do
		try
			# # Sanity check. Make sure that there are no 0's in the last column (which might happen if we're not computing to enough digits).
			# if 0 in { entries(Column(M,n+1), nolist) } then error "(n+1)th column contains 0" fi: # Force the catch: clause, below
			
			# Try to find integer relations using LLL (making sure we're not using integer arithmetic)
			calc := LLL( M, :-integer=false ):
			forget( LLL ):	# Needed to clear the remember table so that LLL calculates the next iteration properly. 
							# (Not 100% sure why this is necessary, but it is something to do with the inplace ColumnOperation below).

			# Find any row which has final entry less than 1 (this may have an linear relation)
			# Note: ideally we're looking for 0 in the last entry, but searching for anything less than 1 seems, experimentally, to work fine.
			epsilon := 1; 

			# Select the row indices of candidate relations (remove the index of any row whose discriminant is not less than epsilon).
			candidates := select( r->LLL_IS_CANDIDATE( calc[r], epsilon ), rowIndices ):

			# Replace the row indices of the candidates with the actual row.
			candidates := map( r->calc[r], candidates ):
			
			# Format each candidate into the required form for output by repaciung the row indices with the formatted data.
			candidates := map( LLL_FORMAT_CANDIDATE, candidates ): 
		catch:
			# If there's an error then manually set candidates to be the empty set.
			candidates := {}:
		finally:
			LLL_UPDATE_LATTICE_MATRIX( M ):
		end try:
	end do:

	# If we get to this point, then either we found posisble integer relations (for some value of k)
	# or we got to k=1 without finding any posisble relation.
	
	# The general output format is either ( {candidates}, [ computation output data ] ) or  ( FAIL, [ computation output data ] )
	if candidates = {} then
		# Return FAIL, and an appropriate output data table containing FAIL_info and appropriate LLL computation info.
		return FAIL, [ (FAIL_info) = "No candidate relations found for this precision", (`LLL InitialN`) = evalf[1](10^K), (LLL_attempts) = K - k ]:
	else
		# We return the result of this, along with the  output table data for this LLL integer relation computation.
		return candidates, [ (`LLL InitialN`) = evalf[1](10^K), (`LLL FinalN`) = evalf[1](10^(k+1)), (`LLL Attempts`) = K - k, (`LLL CandidateRelations`) = numelems(candidates) ]: 
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
	return { [calc,[]] }, []:
end proc:
