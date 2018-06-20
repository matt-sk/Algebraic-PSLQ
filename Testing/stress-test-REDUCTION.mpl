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

# Run the tests.
read "stress-test-common.mpl";