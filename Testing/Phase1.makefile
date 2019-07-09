# Parameters
Thresholds := epsilon epsilon_minus_3 maple
Gammas := 2.0 3.0 # gamma_1 treated separately

# Generate the possible output file names.

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= APSLQ Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

# NOTE: only some input sets are appropriate for the gamma_1 gamma parameter, so we must account for this in the setup.

# Produce a template list for only the gamma_1 capable test sets.
Ph1-APSLQ-gamma_1-OutputFiles := $(APSLQ-gamma_1-TestSets:%=Results/Phase1/%-APSLQ)

# Produce a template list for all test sets (including the ones above)
Ph1-APSLQ-OutputFiles := $(Ph1-APSLQ-gamma_1-OutputFiles) $(APSLQ-no_gamma_1-TestSets:%=Results/Phase1/%-APSLQ)

# Add "-gamma_1-gamma" to only the output file tamplates capable of being processed with gamma_1. 
# NOTE: It is important to do this after makign the 2nd template list above.
Ph1-APSLQ-gamma_1-OutputFiles := $(Ph1-APSLQ-gamma_1-OutputFiles:%=%-gamma_1-gamma)

# Add each of $(Gammas) (appended to "-gamma") to /all/ outputfiles.
Ph1-APSLQ-OutputFiles := $(foreach g,$(Gammas),$(Ph1-APSLQ-OutputFiles:%=%-${g}-gamma))

# Amaglamate the two template lists now that we have properly accounted for the various gamma options.
Ph1-APSLQ-OutputFiles := $(Ph1-APSLQ-gamma_1-OutputFiles) $(Ph1-APSLQ-OutputFiles)

# Add the threshold options to each of the template files.
Ph1-APSLQ-OutputFiles := $(foreach t,$(Thresholds),$(Ph1-APSLQ-OutputFiles:%=%-${t}-threshold))


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= CLASSICAL Integer Relation Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

Ph1-CLASSICAL-PSLQ-OutputFiles := $(CLASSICAL-PSLQ-TestSets:%=Results/Phase1/%-CLASSICAL-PSLQ)

Ph1-CLASSICAL-LLL-OutputFiles := $(CLASSICAL-LLL-TestSets:%=Results/Phase1/%-CLASSICAL-LLL)


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= REDUCTION Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

Ph1-REDUCTION-PSLQ-OutputFiles := $(REDUCTION-PSLQ-TestSets:%=Results/Phase1/%-REDUCTION-PSLQ)

Ph1-REDUCTION-LLL-OutputFiles := $(REDUCTION-LLL-TestSets:%=Results/Phase1/%-REDUCTION-LLL)


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= Intermediate Targets
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
.PHONY: Ph1-Testing Ph1-APSLQ-Testing Ph1-CLASSICAL-Testing Ph1-REDUCTION-Testing Ph1-CLASSICAL-PSLQ-Testing Ph1-CLASSICAL-LLL-Testing Ph1-REDUCTION-PSLQ-Testing Ph1-REDUCTION-LLL-Testing

# Target for all Phase 1 testing
Ph1-Testing: Ph1-APSLQ-Testing Ph1-PSLQ-Testing Ph1-REDUCTION-Testing

# Target for all LLL or PSLQ based computations
Ph1-LLL-Testing: Ph1-CLASSICAL-LLL-Testing Ph1-REDUCTION-LLL-Testing

Ph1-PSLQ-Testing: Ph1-CLASSICAL-PSLQ-Testing Ph1-REDUCTION-PSLQ-Testing

# Targets for testing each conceptual group (classical algebraic relations, REDUCTION method, and Algebraic PSLQ)
Ph1-CLASSICAL-Testing: Ph1-CLASSICAL-PSLQ-Testing Ph1-CLASSICAL-LLL-Testing

Ph1-REDUCTION-Testing: Ph1-REDUCTION-PSLQ-Testing Ph1-REDUCTION-LLL-Testing

Ph1-APSLQ-Testing: $(Ph1-APSLQ-OutputFiles)

# Targets for testing LLL and PSLQ subcases of the conceptual groups which may use either (classical algebraic relations, and REDUCTION method). 
Ph1-CLASSICAL-PSLQ-Testing: $(Ph1-CLASSICAL-PSLQ-OutputFiles)

Ph1-CLASSICAL-LLL-Testing: $(Ph1-CLASSICAL-LLL-OutputFiles)

Ph1-REDUCTION-PSLQ-Testing: $(Ph1-REDUCTION-PSLQ-OutputFiles)

Ph1-REDUCTION-LLL-Testing: $(Ph1-REDUCTION-LLL-OutputFiles)


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= Variables
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

# Phase spewcific variables.
Results/Phase1/%: PHASE=1
Results/Phase1/%: PHASE_DEPENDENCIES=stress-test-PHASE-1.mpl

# Phase 1 Algebraic PSLQ specific variables.
$(Ph1-APSLQ-OutputFiles): GAMMA=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-gamma.*/\1/g')
$(Ph1-APSLQ-OutputFiles): THRESHOLD=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-threshold.*/\1/g')
$(Ph1-APSLQ-OutputFiles): EXTRA_PARAMETERS=-c "PHASE:=1;" -c "Gamma:='$(GAMMA)';" -c 'THRESHOLD:=$(THRESHOLD);' -c 'ITERATIONS:=10000;'