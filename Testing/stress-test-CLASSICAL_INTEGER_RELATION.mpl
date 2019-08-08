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

EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::table;
	local OutputData := table():
	global LLL_Num_Attempts, LLL_Num_Candidates, FAILinfo:

	
	# If the result was a fail, then include the FAILinfo
	if result = FAIL then 
		OutputData[FAIL_info] := FAILinfo: 
#		_extra_output := cat( _extra_output, sprintf( ",FAILinfo=\"%s\"", FAILinfo ) ):
	end if:

	# If we computed the integer relation using LLL, then include the LLL-specivic details of the computation.
	if INTEGER_RELATION_FUNCTION = LLL_INTEGER_RELATION then
		OutputData[LLL_attempts] := LLL_Num_Attempts:
		OutputData[LLL_candidate_relations] := LLL_Num_Candidates:
	end if:

	return OutputData:
end proc:

# Run the tests.
read "stress-test-common.mpl";
