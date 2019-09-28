# Read the definitions of the integer relation computing functions  (PSLQ_ and LLL_INTEGER_RELATION).
read "IntegerRelationFunctions.mpl":

# Define functions used by stress-test-common.mpl

# SETUP(): Function to run before processing to set up thigns that need setting up.
# Additionally, this function is responsible for raising any fatal errors that are contingent on the particulars of the test set.
SETUP := proc( D::integer, coeffDigits::posint )
	global INTEGER_RELATION_FUNCTION, LLL_INTEGER_RELATION:

#	if INTEGER_RELATION_FUNCTION = PSLQ_INTEGER_RELATION and not abs(D) in {0,1} then
	if not abs(D) in {0,1} then
		error "Q[sqrt(%1)] is not a classical case.",D;
	elif INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION then
		if D < 0 then
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC(-1):
		else
			LLL_INTEGER_RELATION := LLL_INTEGER_RELATION_REAL_CLASSICAL:
		end if:
	end if:	

#	elif INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION and not D in {0,1} then
#		error "Cannot use LLL for Q[sqrt(%1)]",D;
#	end if;
end proc:

TEST := proc( xx::~list(complexcons), D::integer, Precision::posint )
	return INTEGER_RELATION_FUNCTION( xx, Precision ):
end proc:

# Run the tests.
read "stress-test-common.mpl";
