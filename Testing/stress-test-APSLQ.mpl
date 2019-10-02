# Function to calcualte the value of gamma_1 (used in SETUP)
gamma_1 := proc( D::integer )
	local discriminant, d;

	if D in {0,1} then
		return sqrt(4/(3));
	elif D < 0 then
		discriminant := D mod 4;
		d := abs(D):
		if discriminant = 1 then
			return -4*sqrt(-(d^2-14*d+1)*d)/(d^2-14*d+1):
		elif discriminant in {2,3} and d<3 then 
			return 2/sqrt(3-d):
		end if:
	end if:

	error "Cannot calculate gamma_1 parameter for D=%1",D:
end proc:

# Define functions used by stress-test-common.mpl

# SETUP(): Function to run before processing to set up thigns that need setting up.
# Additionally, this function is responsible for raising any fatal errors that are contingent on the particulars of the test set.
SETUP := proc( D::integer, coeffDigits::posint )
	global INPUT, OUTPUT, Gamma, THRESHOLD, ITERATIONS, PROFILE, GammaParameter, ThresholdParameter, IterationsParameter, profilefile, APSLQ;
	local origDir;

	# Check to make sure that it makes sense to use APSLQ for this test set. Raise an error if not.
	if D >= 2 then
		error "Cannot use APSLQ for Q[sqrt(%1)]",D;
	end if:

	# Set up parameters for Gamma and Threshold for the APSLQ call.
	# Note that these will be part of a sequence, so nonexistent (or default) ones need to be NULL.
	# Note also that for decimal gamma values like sqrt(2.1) to be evaluated to full precision before the APSLQ call,
	# the value of Gamma *MUST* be surrounded by unevaluation single quotes when set at the command line.

	if (not assigned(Gamma)) or (Gamma=default) then
		GammaParameter := NULL:
	elif Gamma=gamma_1 then
		GammaParameter := gmma=gamma_1(D):
	else
		GammaParameter := 'gmma='Gamma'':
	end if:

	if (not assigned(THRESHOLD)) or (THRESHOLD=default) then
		ThresholdParameter := P->NULL;
	elif THRESHOLD=epsilon then
		ThresholdParameter := P->threshold=10^( -(P-1) );
	elif THRESHOLD=epsilon_minus_3 then
		ThresholdParameter := P->threshold=10^( -(P-4) );
	elif THRESHOLD=epsilon_minus_5 then
		ThresholdParameter := P->threshold=10^( -(P-6) );
	elif THRESHOLD=maple then
		ThresholdParameter := P->threshold=10^( -(P-log[10](2.0*nops(xx))) );
	else
		ThresholdParameter := P->threshold=10^( -trunc(THRESHOLD*P) );
	end if:

	if (not assigned(ITERATIONS)) or (ITERATIONS=default) then
		IterationsParameter := NULL;
	else
		IterationsParameter := iterations=ITERATIONS;
	end if;

	# Read in the APSLQ code.
	origDir := currentdir( "../Maple" ):
	read "APSLQ.module.mpl";
	currentdir( origDir ):

	# Determine whether or not we are profiling the APSLQ and AlgNearest functions.
	if (not assigned(PROFILE)) then
		PROFILE := false;
	elif (not type(PROFILE, 'truefalse')) then
		WARNING( "PROFILE not of type truefalse. Defaulting to PROFILE=false.");
		PROFILE := false;
	fi;

	# Inform the APSLQ module of our profiling status (true or false as appropriate)
	APSLQ:-SetProfiling( PROFILE );

	if PROFILE then
		# We expect to output the profile to a file OUTPUT.profile. Default to /dev/stderr if this file cannot be opened.
		try
			profilefile := fopen( cat(OUTPUT, ".profile"), WRITE, TEXT ):
		catch: 
			profilefile := fopen( "/dev/stderr", WRITE, TEXT ):
		end try:
	end if;

end proc:

TEST := proc( xx::~list(complexcons), D::integer, Precision::posint )
	local calc, str, diagnostics;
	global IterationsParameter, ThresholdParameter, GammaParameter, THRESHOLD;

	# Note that the Digits must be set so that the GammaParameter evaluates to the correct number of decimal places for cases like, say
	# sqrt(2.1). For this to work, the value of Gamma *MUST* be surrounde by unevaluation single quotes when set at the command line.
	try
		if THRESHOLD=maple then
			Digits := Precision+5;
			calc := APSLQ[APSLQ]( xx, -D, digits=Precision+5, ThresholdParameter(Precision), eval(GammaParameter), IterationsParameter ):
		else
			Digits := Precision;
			calc := APSLQ[APSLQ]( xx, -D, digits=Precision, ThresholdParameter(Precision), eval(GammaParameter), IterationsParameter ):
		end if;
	catch:
		# If an exception occurs while computing APSLQ, we reproduce the test, and record it as FAIL_Info in the output data table.
		if lastexception[1] <> 0 then str := sprintf( " (in %s)", lastexception[1] ): else str := "": fi:
		return FAIL, [ (FAIL_Info) = sprintf( "%s%s", StringTools[FormatMessage](lastexception[2..-1]), str ) ]:
	end try:

	# Retrieve runtime diagnostics.
	diagnostics := APSLQ:-GetDiagnostics( ):

	if calc = FAIL then
		# Return FAIL, and an appropriate output data table containing FAIL_info and appropriate APSLQ computation info.
		return FAIL, [ (FAIL_Info) = "Maximum iteration count exceeded" ]:
	else
		# Return the calcualted relation as the only element of a singleton set, along with the output table data for this APSLQ integer relation computation.
		# Note that the miny diagnostics gives a list of all of the minimum y values from the computations. Nops is therefore the number of iterations.
		return { [calc, []] }, [ (`APSLQ Iterations`) = nops(diagnostics[miny]), (`APSLQ Significance`) = diagnostics[sig], (`APSLQ Warning`) = diagnostics[warning] ];
	end if:
end proc:

TIDYUP := proc( )
	global profilefile, APSLQ;

	if PROFILE then
		fprintf( profilefile, "%s", APSLQ:-GetProfile() ):
		fclose(profilefile):
	end if;
end proc:

# Run the tests.
read "stress-test-common.mpl";
