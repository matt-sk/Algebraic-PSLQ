# Assume INPUT_FILENAME is specified.

INPUT_FILE := fopen( INPUT_FILENAME, READ, TEXT ):

parametersString := readline(INPUT_FILE):
parameters := parse( parametersString, 'statement' ):

while true do
   line := readline( INPUT_FILE ):
	if line = 0 then break fi:

	line := parse( line ):

	# Extract the ID.
	ID := line[id]:

	# Extract non-zero coefficients
	C1 := line[coeffs]:
	C2 := map( z->(Re(z),Im(z)), line[coeffs] ):

	C1 := remove( z->is(z=0), C1 ):
	C2 := remove( z->is(z=0), C2 ):

	# Count the digits of each integer in the linsts
	C1 := map( z->ilog10(z)+1, C1 ):
	C2 := map( z->ilog10(z)+1, C2 ):

	# Output the counts.
	printf( "%d,%d,%d\n", ID, add( z, z in C1 ), add( z, z in C2 ) ):
end:
