# Set up functions used by stress-test-common.mpl
TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
	uses IntegerRelations;

	if not abs(D) in {0,1} then
		error "Cannot use PSLQ for Q[sqrt(%1)]",D;
	end if;

	Digits := Precision;
	return PSLQ( xx );
end proc:

# Run the tests.
read "stress-test-common.mpl";