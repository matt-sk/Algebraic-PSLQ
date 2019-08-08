# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Preprocessing setup of I/O file names.                                                                        =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =- 
$ifdef __INPUT
	INPUT := __INPUT:
	printf( "INPUT: %a, __INPUT, %a\n", INPUT, __INPUT ):
$endif

$ifdef __OUTPUT
	OUTPUT := __OUTPUT:
$endif

$ifdef __PHASE
	PHASE := __PHASE:
$endif

# Function to output error messages and terminate the program. Don't take the name too seriously.
TerminateAndCatchFire := proc( errorcode::integer )
	description " Mimick the output of an error call before quitting with an error value.";
	local str := "":

	if lastexception[1] <> 0 then str := sprintf( " (in %a)", lastexception[1] ) fi;
	printf( "%s: Error,%s %s\n", OUTPUT, str, StringTools[FormatMessage](lastexception[2..-1]) );
	`quit`( errorcode ):	
end proc:

# Process input and output 
try
	if (not assigned(OUTPUT)) or (OUTPUT=default) or (not type(OUTPUT,string)) then
		OUTPUT := "/dev/stdout":
	end if:
	outfile := fopen( OUTPUT, WRITE, TEXT );

	if not assigned(INPUT) then
		ERROR( "no input file" ):
	else
		testfile := fopen( INPUT, READ, TEXT ):
	end if:

	SnapshotFileName := cat( ".", FileTools[Filename](OUTPUT), ".snapshot.m" ):

catch :
	TerminateAndCatchFire( 1 ):

end try:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# Note that the calc input for many of these might be a vector or list (the calculated integer relation) or it might be FAIL if the calculation went awry somehow.
# As such, it is not given an explicit type in any of the following function definitions.

# The TEST() function needs to be set by the specific test script.
# Note that this must be a function so the error is raised inside the try-catch block below.
if not assigned( TEST ) then
WARNING( "Reassigning TEST" ):
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
# This function must return either CONTINUE to allow further checking, or one of GOOD, BAD, or FAIL to report an outcome.
if not assigned( PRECHECK ) then
	PRECHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		if calc = FAIL then
			return FAIL
		else
			return CONTINUE
		end if;
	end proc:
end if:

# POSTCHECK(): Function run before standard results checking is run.
# This function must return GOOD, BAD, FAIL to report an outcome, or CONTINUE to allow further checking.
if not assigned( POSTCHECK ) then
	POSTCHECK := proc( result, relation, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::boolean_constant;
		return result; # Do nothing, return the previously found result.
	end proc:
end if:

# EXTRAOUTPUT(): Function run after standard outputting is performed, but before newline is output.
# result will be one of GOOD, BAD, FAIL, or UNEXPECTED
if not assigned( EXTRAOUTPUT ) then
	EXTRAOUTPUT := proc( result, relation, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )::table;
		return table();
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

# Note that the calc input for many of these might be a vector or list (the calculated integer relation) or it might be FAIL if the calculation went awry somehow.
# As such, it is not given an explicit type in any of the following function definitions.

# This function checks the result of a computation.
# To be passed in for testing.
CHECK := proc( calc, xx::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, ans::{list(complexcons),'Vector'(complexcons),'vector'(complexcons)}, D::integer, Precision::posint )
	local k, mult, XX1, rel, preResult, result, relation, savedUnexpectedRelation, savedBadRelation;
	global CHK, GOOD, BAD, UNEXPECTED;

	# In the case that the result is not GOOD, CHK will store the numeric value of the expanded numeric check, and this value is appended to the output.
	# We should initialise it to something inocuous just in case the PRECHECK causes this procedure to exit with a result other than GOOD.
	CHK := "":

	# Pre Check
	preResult := PRECHECK( calc, xx, D, Precision ):
	if preResult <> CONTINUE then return preResult, [] fi:

	savedUnexpectedRelation := NULL:

	# Check to see if the calculated relation is just an algebraic integer multiple of the known relation.
	# To do this we calculte the multiple that turns ans[1] into calc[1] and multiply the entire ans list by this multiple.
	# If the two lists are then the same, we found such a multiple of the known relation.
	for relation in calc do
		mult := -relation[1]; # We know ans[1] = -1, so if relation = k*ans for some algebraic integer k, then k=-calc[1].
		CHK := expand(relation-ans*mult):

		if convert(CHK,set) = {0} then
		   result := GOOD:
		   CHK := 0.0: # Needed in case POSTCHECK changes the result from GOOD to somethign else.
		   break:
		else
			rel := expand( add( xx[k]*relation[k], k=1..nops(xx) ) ):
			Digits := 1000;
			CHK := abs( evalf[1000](rel) ):
			if CHK < 10^(-998) then
				result := UNEXPECTED:
				savedUnexpectedRelation := relation:
			else
				result := BAD:
				savedBadRelation := relation:
			end if:
		end if:
	end do:


	# If we found a GOOD result we stop immediately. Otherwise we may have a BAD or UNEXPECTED result.
	# If the result is BAD, check to see if we saved an UNEXPECTED result beforehand, otherwise use the .
	if result = BAD then
		if savedUnexpectedRelation <> NULL then:
			result := UNEXPECTED:
			relation := savedUnexpectedRelation:
		else
			relation := savedBadRelation:
		end if:
	end if:

#printf( " - Final: %a\n", result ):

	return POSTCHECK( result, relation, xx, D, Precision ), relation:
end proc:

CALCULATE_TEST_PROBLEM := proc( xx::~list(complexcons), ans::~list(complexcons), precision::posint, $ )
	option remember:
	global d:
	local calc, rel, result, output, START, END;

	# Run the integer relation computation, and time how long it takes.
	START := time():
	calc := TEST( xx, d, precision ):
	END := time():

	# Note that the calc variable may have multiple candidate relations.
	# The CHECK function scans through these and returns the best result possible, as well as the relation (if any).
	result,rel  := CHECK( calc, xx, ans, d, precision );
	 
	output := EXTRAOUTPUT(RESULT, rel, xx, d, precision);
	output[Result] := result:
	output[Precision] := precision:
	output[CalculationTime] := END-START:
	
	if result = GOOD then
		output[Mult] := -rel[1]:
	elif (result = UNEXPECTED) or (result = BAD) then
		output[Relation] := rel:
		output[Check] := evalf[2](CHK):
	end if:

	# Return all relvant information in a table.
	return table( [Result=result, Relation=rel, OutputData=eval(output)] ):
end proc;

# Read the script which defines the function to process the individual tests.
# Should define PROCESS_LINE( line::table )
processingFile := cat("stress-test-PHASE-", PHASE, ".mpl"):
read processingFile;

# Define a snapshotting wrapper for 
try
	# Try to read the snapshot file. If successful, this will restore the remember table from the most recent computation for the output file.
	read( SnapshotFileName );

catch :
	# We end up here if some calamity occurs in reading the snapshot file.
	# Usually this will be becuase we are startign a fresh computation, and the snapshot file does not yet exist.

	# Set up a new function with an empty remember table.
	PROCESS_LINE := proc( _line::string )
		description "Run PROCESS_LINE, and store the result in a remember table.":
		option remember:

		# Process the test problem (saving the returned table).
		local line := parse( _line, statement ):
		local outputData := PROCESS_TEST_PROBLEM( line ): 

		# Append the line ID to the output.
		outputData[ID] := line[id]:

		# Need to use eval to make sure the remember table stores the actual table and not just the literal `outputData`.
		return eval(outputData):
	end proc:

end try:

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
# -= Main Processing                                                                                               =-
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# There's no point encasing this in a try-catch block. Anyerrors in the processingFile are not passed back and caught.
# Furthermore, without the try-catch block, any error during processingFile causes an immediate termination of computatoin (and so the snapshot file isn't removed).
parametersString := readline(testfile):
parameters := parse( parametersString, 'statement' );

consts := parameters[consts];
d := parameters[affix]:
coeffDigits := parameters[digits]:

SETUP( d, coeffDigits ):
GOODcount,BADcount,UNEXPECTEDcount,FAILcount := 0,0,0,0:

START := time():

# lineCount should agree with line[id] from the input file, but it doesn' tmatter if it doesn't.
# We just use it for a unique input into the PROCESS_LINE file so that each input has a saved output.
do 
	# Read the line
	line := readline( testfile ):
	if line = 0 then break: fi:
	
	# Read and process the line.
	OutputData := PROCESS_LINE( line ): #parse(line, statement) ):

	# CHeck for termination condition (end of file)
	if OutputData = EOF then break: fi:

	# Snapshot the progress.
	save( PROCESS_LINE, SnapshotFileName ):

	# Extract the result.
	result := OutputData[Result]:

	# Increment the count for this result (GOODcount, BADcount, etc)
	cat(result,count) := eval(cat(result,count)) + 1;

	# Output the results.
	fprintf( outfile, "%a\n", eval(OutputData) ):	
end do:

END := time():

# Print out a completion message with time taken to process and result counts.
printf("%s complete. %a seconds duration. %a good examples, %a unexpected examples, %a bad examples, %a fails.\n", OUTPUT, END-START, GOODcount, UNEXPECTEDcount, BADcount, FAILcount);

# Clean up.
fclose( testfile ):
fclose( outfile ):
fremove( SnapshotFileName ):

TIDYUP():

