# Assume INPUT_FILENAME is specified.

INPUT_FILE := fopen( INPUT_FILENAME, READ, TEXT ):

parametersString := readline(INPUT_FILE):
parameters := parse( parametersString, 'statement' ):


# Warning: if this function is not given a proper algebraic integer, it will give potentially bad results.
algCoeffs := proc(z,d::integer)
	local a,b,c:

	if d < 0 then 
		a,b := Re(z), Im(z):
		if d < -1 then b := coeff(b, sqrt(abs(d))) fi:
	elif d > 1 then
		a,b := coeff(z, sqrt(d), 0), coeff(z, sqrt(d), 1)
	else
		return z;
	end if:

	# If we get here then we definitely are expecting an algebraic integer (as opposed to a regular integer).
	if d mod 4 = 1 then
		c := a-b, 2*b:
	else
		c := a,b:
	end if:

	return c:
end proc:

while true do
	line := readline( INPUT_FILE ):
	if line = 0 then break fi:

	line := parse( line ):

	# Extract the ID.
	ID := line[id]:

	C := line[coeffs]:

	# Extract non-zero coefficients
	C1 := map( (x,d)->max(map(abs, [algCoeffs(x,d)])), line[coeffs], parameters[affix] ):
	C2 := map( algCoeffs, line[coeffs], parameters[affix] ):

	C1 := remove( z->is(z=0), C1 ):
	C2 := remove( z->is(z=0), C2 ):

	# Count the digits of each integer in the linsts
	C1 := map( z->ilog10(z)+1, C1 ):
	C2 := map( z->ilog10(z)+1, C2 ):
	
	# Output the counts.
	printf( "%d,%d,%d\n", ID, add( z, z in C1 ), add( z, z in C2 ) ):
end:
