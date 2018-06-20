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

# The TEST() function needs to be set by the specific test script.
# Note that this must be a function so the error is raised inside the try-catch block below.
if not assigned( TEST ) then
	TEST := proc( xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
		error "TEST Function needs to be Redefined";
	end proc;
end if:

# The remaining two functions are optional. If not set by the test script then the following definitions are used.

# SETUP(): Function to run before processing to set up thigns that need setting up.
if not assigned( SETUP ) then
	SETUP := proc( D::integer, coeffDigits::posint )
	end proc:
end if:

# PRECHECK(): Function run before standard results checking is run.
# This function must return GOOD, BAD, FAIL to report an outcome, or CONTINUE to allow further checking.
if not assigned( PRECHECK ) then
	PRECHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		return CONTINUE;
	end proc:
end if:

# EXTRAOUTPUT(): Function run after standard outputting is performed, but before newline is output.
# result will be one of GOOD, BAD, FAIL, or UNEXPECTED
if not assigned( EXTRAOUTPUT ) then
	EXTRAOUTPUT := proc( result, calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::string;
		return "";
	end proc:
end if:

# TIDYUP() : Function to run after all processing is complete.
if not assigned( TIDYUP ) then
	TIDYUP := proc()
	end proc:
end if:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Utility function declaration.                                                                                 =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# This function checks the result of a computation.
# Note that calc needs to be anything, since APSLQ occasionally returns "FAIL" and we need to allow these bad values
# To be passed in for testing.
CHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, ans::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
	local mult, XX1, rel;
	global CHK, GOOD, BAD, UNEXPECTED;

	# Pre Check
	CHK := PRECHECK( calc, xx, D, Precision ):
	if CHK <> CONTINUE then return CHK fi:

	# Check to see if the calculated relation is just an algebraic integer multiple of the known relation.
	# To do this we calculte the multiple that turns ans[1] into calc[1] and multiply the entire ans list by this multiple.
	# If the two lists are then the same, we found such a multiple of the known relation.
	mult := expand(calc[1]*conjugate(ans[1]))/expand(ans[1]*conjugate(ans[1])):
	CHK := expand(calc-ans*mult):

	if convert(CHK,set) = {0} then
	   return GOOD:
	else
		rel := expand( add( xx[k]*calc[k], k=1..nops(xx) ) ):
		Digits := 1000;
		CHK := abs( evalf[1000](rel) ):
		if CHK < 10^(-998) then
			return UNEXPECTED:
		else
			return BAD:
		end if:
	end if:
end proc:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Main Processing                                                                                               =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# Run the tests.
processingFile := cat("stress-test-PHASE-", PHASE, ".mpl"):
read processingFile;