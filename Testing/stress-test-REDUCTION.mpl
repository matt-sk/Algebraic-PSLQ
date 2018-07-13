# Set up functions used by stress-test-common.mpl
TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
	local omega, xxE, calc:
	uses IntegerRelations:

	if abs(D) in {0,1} then
		error "Pointless using REDUCTION method for an example that can be directly performed with PSLQ":
	end if:
	
	# Set the precision. We need this now so that our calculation of xxE is correct.
	Digits := Precision:

	# We extend the input list by taking each element, x,  and replacing it with x, omega*x
	omega := piecewise( D mod 4 = 1, (1+sqrt(D))/2, sqrt(D) ):
	xxE := map( x -> (x, omega*x), xx ):

	# Run PSLQ
	calc := PSLQ(xxE):

	# Recover the algebraic integer relations from the PSLQ output.
	calc := [ seq( calc[2*k-1]+omega*calc[2*k], k = 1 .. (nops(xxE)/2 ) ) ]:
	calc := map( expand, calc ):

	return calc:
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

POSTCHECK := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
	local chk:
	global ORIG_RESULT:

	# No post-checking needed for the real case (or even for Gaussian integers, since REDUCTION is pointless in that case)
	if D >= -1 then return result: fi:

	# We only need to do additional checking if the result was GOOD
	if result <> GOOD then return result: fi:

	# We check to make sure that the elements of the integer relation are, in fact, quadratic integers from the correct sinple quadratic extension field.
	chk := { seq( type(calc[k], SmplCplxQuadInt(D) ), k=1..nops(xx) ) }:
	if `and`( op(chk) ) then
		return result: # Result should be good, but whatever it is, it's preserved.
	else
		ORIG_RESULT := result:
		return FAIL:
	end if:
end proc:

EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::string;
	global ORIG_RESULT:

	if result = FAIL then
		return sprintf( ",OriginalResult=%s", ORIG_RESULT );
	else
		return "";
	end if:
end proc:


# Run the tests.
read "stress-test-common.mpl";