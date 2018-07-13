# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Preprocessing setup of I/O file names.                                                                        =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =- 
$ifdef __INPUT
	INPUT := __INPUT:
$endif

$ifdef __OUTPUT
	OUTPUT := __OUTPUT:
$endif

$ifdef __PHASE
	PHASE := __PHASE:
$endif

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Callback function declaration.                                                                                =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= These are function hooks that can be over-ridden by the scripts using this common framework                   =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# Note that the calc input for many of these might be a vector or list (the calculated integer relation) or it might be FAIL if the calculation went awry somehow.
# As such, it is not given an explicit type in any of the following function definitions.

# The TEST() function needs to be set by the specific test script.
# Note that this must be a function so the error is raised inside the try-catch block below.
if not assigned( TEST ) then
	TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
		option inline:
		error "TEST Function needs to be Redefined";
	end proc;
end if:

# The remaining two functions are optional. If not set by the test script then the following definitions are used.

# SETUP(): Function to run before processing to set up thigns that need setting up.
if not assigned( SETUP ) then
	SETUP := proc( D::integer, coeffDigits::posint )
		option inline:
	end proc:
end if:

# PRECHECK(): Function run before standard results checking is run.
# This function must return either CONTINUE to allow further checking, or one of GOOD, BAD, or FAIL to report an outcome.
if not assigned( PRECHECK ) then
	PRECHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		option inline:
		return CONTINUE;
	end proc:
end if:

# POSTCHECK(): Function run before standard results checking is run.
# This function must return GOOD, BAD, FAIL to report an outcome, or CONTINUE to allow further checking.
if not assigned( POSTCHECK ) then
	POSTCHECK := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		option inline:
		return result; # Do nothing, return the previously found result.
	end proc:
end if:

# EXTRAOUTPUT(): Function run after standard outputting is performed, but before newline is output.
# result will be one of GOOD, BAD, FAIL, or UNEXPECTED
if not assigned( EXTRAOUTPUT ) then
	EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::string;
		option inline:
		return "";
	end proc:
end if:

# TIDYUP() : Function to run after all processing is complete.
if not assigned( TIDYUP ) then
	TIDYUP := proc()
		option inline:
	end proc:
end if:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Utility function declaration.                                                                                 =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# Note that the calc input for many of these might be a vector or list (the calculated integer relation) or it might be FAIL if the calculation went awry somehow.
# As such, it is not given an explicit type in any of the following function definitions.

# This function checks the result of a computation.
# To be passed in for testing.
CHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, ans::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
	local mult, XX1, rel, preResult, result;
	global CHK, GOOD, BAD, UNEXPECTED;

	# In the case that the result is not GOOD, CHK will store the numeric value of the expanded numeric check, and this value is appended to the output.
	# We should initialise it to something inocuous just in case the PRECHECK causes this procedure to exit with a result other than GOOD.
	CHK := "":

	# Pre Check
	preResult := PRECHECK( calc, xx, D, Precision ):
	if preResult <> CONTINUE then return preResult fi:

	# Check to see if the calculated relation is just an algebraic integer multiple of the known relation.
	# To do this we calculte the multiple that turns ans[1] into calc[1] and multiply the entire ans list by this multiple.
	# If the two lists are then the same, we found such a multiple of the known relation.
	mult := -calc[1]; # We know ans[1] = -1, so if calc = k*ans for some algebraic integer k, then k=-calc[1].
	CHK := expand(calc-ans*mult):

	if convert(CHK,set) = {0} then
	   result := GOOD:
	   CHK := 0.0; # Needed in case POSTCHECK changes the result from GOOD to somethign else.
	else
		rel := expand( add( xx[k]*calc[k], k=1..nops(xx) ) ):
		Digits := 1000;
		CHK := abs( evalf[1000](rel) ):
		if CHK < 10^(-998) then
			result := UNEXPECTED:
		else
			result := BAD:
		end if:
	end if:

	return POSTCHECK( result, calc, xx, D, Precision ):
end proc:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Main Processing                                                                                               =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# Run the tests.
processingFile := cat("stress-test-PHASE-", PHASE, ".mpl"):
read processingFile;