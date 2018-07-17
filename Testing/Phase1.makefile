# Parameters
Thresholds := epsilon epsilon_minus_3 maple
Gammas := 2.0 3.0 # gamma_1 treated separately

# Generate the possible output file names.
# Only some input sets are appropriate for the gamma_1 gamma parameter, so we must account for this in the setup.

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

# The PSLQ and REDUCTION sets don't need as much processing. We produce them 
Ph1-PSLQ-OutputFiles := $(PSLQ-TestSets:%=Results/Phase1/%-PSLQ)

Ph1-REDUCTION-OutputFiles := $(REDUCTION-TestSets:%=Results/Phase1/%-REDUCTION)

# Rules
.PHONY: Ph1-Testing Ph1-APSLQ-Testing Ph1-PSLQ-Testing Ph1-REDUCTION-Testing 

Ph1-Testing: Ph1-APSLQ-Testing Ph1-PSLQ-Testing Ph1-REDUCTION-Testing

Ph1-APSLQ-Testing: $(Ph1-APSLQ-OutputFiles)

Ph1-PSLQ-Testing: $(Ph1-PSLQ-OutputFiles)

Ph1-REDUCTION-Testing: $(Ph1-REDUCTION-OutputFiles)

Results/Phase1/%: PHASE=1
Results/Phase1/%: PHASE_DEPENDENCIES=stress-test-PHASE-1.mpl

$(Ph1-APSLQ-OutputFiles): GAMMA=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-gamma.*/\1/g')
$(Ph1-APSLQ-OutputFiles): THRESHOLD=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-threshold.*/\1/g')
$(Ph1-APSLQ-OutputFiles): EXTRA_PARAMETERS=-c "PHASE:=1;" -c "Gamma:='$(GAMMA)';" -c 'THRESHOLD:=$(THRESHOLD);' -c 'ITERATIONS:=10000;'