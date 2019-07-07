read "IntegerRelationFunctions.mpl":

# Set up functions used by stress-test-common.mpl
TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )

	if INTEGER_RELATION_FUNCTION = PSLQ_INTEGER_RELATION and not abs(D) in {0,1} then
		error "Cannot use PSLQ for Q[sqrt(%1)]",D;
	elif INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION and not D in {0,1} then
		error "Cannot use LLL for Q[sqrt(%1)]",D;
	end if;

	return INTEGER_RELATION_FUNCTION( xx, Precision ):
end proc:

EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::string;
	local _extra_output := "":
	global LLL_Num_Attempts, LLL_Num_Candidates:

	if INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION then
		_extra_output := sprintf( ",LLL_attempts=%a,CandidateRelations=%a", LLL_Num_Attempts, LLL_Num_Candidates ):
	end if:

	return _extra_output:
end proc:

# Run the tests.
read "stress-test-common.mpl";