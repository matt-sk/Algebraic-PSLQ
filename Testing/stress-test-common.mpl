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
	TEST := proc( xx::~list(complexcons), D::integer, Precision::posint )
		error "TEST Function needs to be Redefined";
	end proc;
end if:

# The remaining two functions are optional. If not set by the test script then the following definitions are used.

# SETUP(): Function to run before processing to set up thigns that need setting up.
# Additionally, this function is responsible for raising any fatal errors that are contingent on the particulars of the test set.
if not assigned( SETUP ) then
	SETUP := proc( D::integer, coeffDigits::posint )
	end proc:
end if:

# PRECHECK(): Function run before standard results checking is run.
# This function must return a set of candidate relations for checking. This set must be empty to indicate a FAIL result.
if not assigned( PRECHECK ) then
	PRECHECK := proc( calc, xx::~list(complexcons), D::integer, Precision::posint )::set;
		if calc = FAIL then
			return {}
		else
			return calc
		end if:
	end proc:
end if:

# POSTCHECK(): Function run after standard results checking is run.
# This function must return result in {GOOD, UNEXPECTED, BAD, FAIL} to report an outcome, and an output data list.
if not assigned( POSTCHECK ) then
	POSTCHECK := proc( result, relation, xx::~list(complexcons), D::integer, Precision::posint )
		return result, []; # Do nothing, return the previously found result.
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
CHECK := proc( calc, xx::~list(complexcons), ans::~list(complexcons), D::integer, Precision::posint, $ )
	local mult, CHK, result, rel, relation, candidate, candidates, candidateSpecificInfo, calcMult, calcRelation, calcCheck, PostCheckData:

	# Initialisation
	result			:= FAIL:
	calcRelation	:= NULL:
	calcMult		:= NULL: # Default unless a GOOD result is found, in which case we overwrite this variable.
	calcCheck		:= NULL:

	# Pre Check
	candidates := PRECHECK( calc, xx, D, Precision ):

	if candidates <> {} then
		# Only perform checking (including POSTCHECK) if the PRECHECK was successful.

		for candidate in candidates do

			relation := candidate[1]:

			# Check to see if the calculated relation is just an algebraic integer multiple of the known relation.
			# To do this we calculte the multiple that turns ans[1] into calc[1] and multiply the entire ans list by this multiple.
			# If the two lists are then the same, we found such a multiple of the known relation.
			mult := -relation[1]; # We know ans[1] = -1, so if relation = k*ans for some algebraic integer k, then k=-calc[1].
			CHK := expand(relation-ans*mult):

			if convert(CHK,set) = {0} then
				# New result is GOOD
				result := GOOD:
				candidateSpecificInfo := op(candidate[2]):
				calcMult := (Mult)=mult:
				calcRelation := (Relation)=relation:
				calcCheck := NULL:
				break:
			else
				# The new result is either UNEXPECTED, or BAD
				rel := expand( add( xx[k]*relation[k], k=1..nops(xx) ) ):
				Digits := 1000;
				CHK := abs( evalf[1000](rel) ):

				if CHK < 10^(-998) and result in {FAIL, BAD} then
					# New result is UNEXPECTED (only update if old result was BAD or FAIL)
					result := UNEXPECTED:
					candidateSpecificInfo := op(candidate[2]):
					calcRelation := (Relation)=relation:
					calcCheck := (Check)=CHK:
					# calcMult is already NULL
				elif result = FAIL then
					# New result is BAD (only update if old result was FAIL)
					result := BAD:
					candidateSpecificInfo := op(candidate[2]):
					calcRelation := (Relation)=relation:
					calcCheck := (Check)=CHK:
					# calcMult is already NULL
				end if:
			end if:
		end do:

		# Run the POSTCHECK.
		result, PostCheckData := POSTCHECK( result, rhs(calcRelation), xx, D, Precision ):

		# If we have a GOOD result, then the relation is entirely redundant (but was necessary for the POSTCHECK).
		if result = GOOD then calcRelation := NULL: fi:
	end if:

	# Return the result along with amalgamated output table data for this CHECK.
	# Note that some of these may be NULL, in which case they vanish.
	return result, [ calcMult, calcRelation, calcCheck, candidateSpecificInfo, op(PostCheckData) ]:
end proc:

CALCULATE_TEST_PROBLEM := proc( xx::~list(complexcons), ans::~list(complexcons), precision::posint, $ )
	local calc, START, END, result, CheckData, TestData;

	# Run the integer relation computation, and time how long it takes.
	START := time():
	calc, TestData := TEST( xx, d, precision ):
	END := time():

	# Note that the calc variable may have multiple candidate relations.
	# The CHECK function scans through these and returns the best result possible, as well as the relation (if any).
	result, CheckData := CHECK( calc, xx, ans, d, precision ):

	# Return the result along with amalgamated output table data for this run.
	return result, [ (PrecisionUsed) = precision, (CalculationTime) = END-START, op(CheckData), op(TestData) ]:
end proc:

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

		local line, result, OutputData:

		# Process the test problem (saving the returned table).
		line := parse( _line, statement ):
		result, OutputData := PROCESS_TEST_PROBLEM( line ): # Defined in stress-test-PHASE-n.mpl

		# Construct and return the output table data.
		return [ (ID)=line[id], (Result)=result, op( OutputData ) ]:
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

# Set up the processing for the test set. Terminate if an ERROR is raised.
try 
	SETUP( d, coeffDigits ):
catch:
	TerminateAndCatchFire( 1 ):
end try:

ResultCount := table( [GOOD=0, UNEXPECTED=0, BAD=0, FAIL=0] ):

# OutputData := table():
START := time():

# lineCount should agree with line[id] from the input file, but it doesn' tmatter if it doesn't.
# We just use it for a unique input into the PROCESS_LINE file so that each input has a saved output.
do 
	# Read the line (and break loop if end of file)
	line := readline( testfile ):
	if line = 0 then break: fi:

	# Process the line.
	outputData := PROCESS_LINE(line): 

	# Snapshot the progress.
	save( PROCESS_LINE, SnapshotFileName ):

	# Update result counts. (global OutputData table created by PROCESS_LINE)
	result := rhs( outputData[2] ): # Result is guaranteed to be the 2nd element of the returned list.
	ResultCount[result] := ResultCount[result] + 1:

	# Output the results. (Due to the wierd ordering above, we construct the table with the string for the argument list)
	fprintf( outfile, "table(%a)\n", outputData ):
end do:

END := time():

# Print out a completion message with time taken to process and result counts.
printf("%s complete. %a seconds duration. %a good examples, %a unexpected examples, %a bad examples, %a fails.\n", OUTPUT, END-START, ResultCount[GOOD], ResultCount[UNEXPECTED], ResultCount[BAD], ResultCount[FAIL]);

# Clean up.
fclose( testfile ):
fclose( outfile ):
fremove( SnapshotFileName ):

TIDYUP():

