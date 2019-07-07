# Parameters
Thresholds := epsilon
Gammas := 2.0 3.0 4.0 # gamma_1 treated separately
Lengths := short long

# Generate the possible output files.

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= APSLQ Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

# Create seperate lists for the “long” and “short” input cases. (This allows us to make them separately)
Ph2-APSLQ-Short-OutputFiles := $(APSLQ-gamma_1-TestSets:%=Results/Phase2/%-short-input-APSLQ) $(APSLQ-no_gamma_1-TestSets:%=Results/Phase2/%-short-input-APSLQ)
Ph2-APSLQ-Long-OutputFiles := $(APSLQ-gamma_1-TestSets:%=Results/Phase2/%-long-input-APSLQ) $(APSLQ-no_gamma_1-TestSets:%=Results/Phase2/%-long-input-APSLQ)

# Only some input sets are appropriate for the gamma_1 gamma parameter, so we must account for this by producing 
# a template list for only the gamma_1 capable test sets. (Note that we need both -short-input- and -long-input- files)
Ph2-APSLQ-Short-gamma_1-OutputFiles := $(APSLQ-gamma_1-TestSets:%=Results/Phase2/%-short-input-APSLQ)
Ph2-APSLQ-Long-gamma_1-OutputFiles := $(APSLQ-gamma_1-TestSets:%=Results/Phase2/%-long-input-APSLQ)

# Add "-gamma_1-gamma" to only the output file tamplates capable of being processed with gamma_1. 
Ph2-APSLQ-Short-gamma_1-OutputFiles := $(Ph2-APSLQ-Short-gamma_1-OutputFiles:%=%-gamma_1-gamma)
Ph2-APSLQ-Long-gamma_1-OutputFiles := $(Ph2-APSLQ-Long-gamma_1-OutputFiles:%=%-gamma_1-gamma)

# Add each of $(Gammas) (appended to "-gamma") to /all/ outputfiles.
Ph2-APSLQ-Short-OutputFiles := $(foreach g,$(Gammas),$(Ph2-APSLQ-Short-OutputFiles:%=%-${g}-gamma))
Ph2-APSLQ-Long-OutputFiles := $(foreach g,$(Gammas),$(Ph2-APSLQ-Long-OutputFiles:%=%-${g}-gamma))

# Amaglamate the two template lists now that we have properly accounted for the various gamma options.
Ph2-APSLQ-Short-OutputFiles := $(Ph2-APSLQ-Short-gamma_1-OutputFiles) $(Ph2-APSLQ-Short-OutputFiles)
Ph2-APSLQ-Long-OutputFiles := $(Ph2-APSLQ-Long-gamma_1-OutputFiles) $(Ph2-APSLQ-Long-OutputFiles)

# Add the threshold options to each of the template files. (There's only one, but we leave this here in case we ever want to try more).
Ph2-APSLQ-Short-OutputFiles := $(foreach t,$(Thresholds),$(Ph2-APSLQ-Short-OutputFiles:%=%-${t}-threshold))
Ph2-APSLQ-Long-OutputFiles := $(foreach t,$(Thresholds),$(Ph2-APSLQ-Long-OutputFiles:%=%-${t}-threshold))

# # Amalgamate all the APSLQ output files into a single list.
# Ph2-APSLQ-OutputFiles := $(Ph2-APSLQ-Short-OutputFiles) $(Ph2-APSLQ-Long-OutputFiles)


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= CLASSICAL Integer Relation Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

# Create seperate lists for the “long” and “short” input cases. (This allows us to make them separately)
Ph2-CLASSICAL-PSLQ-Short-OutputFiles := $(CLASSICAL-PSLQ-TestSets:%=Results/Phase2/%-short-input-CLASSICAL-PSLQ)
Ph2-CLASSICAL-PSLQ-Long-OutputFiles := $(CLASSICAL-PSLQ-TestSets:%=Results/Phase2/%-long-input-CLASSICAL-PSLQ)
Ph2-CLASSICAL-LLL-Short-OutputFiles := $(CLASSICAL-LLL-TestSets:%=Results/Phase2/%-short-input-CLASSICAL-LLL)
Ph2-CLASSICAL-LLL-Long-OutputFiles := $(CLASSICAL-LLL-TestSets:%=Results/Phase2/%-long-input-CLASSICAL-LLL)

# # Amalgamate the long and short lists into a single list.
# Ph2-CLASSICAL-PSLQ-OutputFiles := $(Ph2-CLASSICAL-PSLQ-Short-OutputFiles) $(Ph2-CLASSICAL-PSLQ-Long-OutputFiles)
# Ph2-CLASSICAL-LLL-OutputFiles := $(Ph2-CLASSICAL-LLL-Short-OutputFiles) $(Ph2-CLASSICAL-LLL-Long-OutputFiles)

# # Amalgamate PSLQ and LLL lists into a single list.
# Ph2-CLASSICAL-OutputFiles := $(Ph2-CLASSICAL-PSLQ-OutputFiles) $(Ph2-CLASSICAL-LLL-OutputFiles)

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= REDUCTION Output Files
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-

# Create seperate lists for the “long” and “short” input cases. (This allows us to make them separately)
Ph2-REDUCTION-PSLQ-Short-OutputFiles := $(REDUCTION-PSLQ-TestSets:%=Results/Phase2/%-short-input-REDUCTION-PSLQ)
Ph2-REDUCTION-PSLQ-Long-OutputFiles := $(REDUCTION-PSLQ-TestSets:%=Results/Phase2/%-long-input-REDUCTION-PSLQ)
Ph2-REDUCTION-LLL-Short-OutputFiles := $(REDUCTION-LLL-TestSets:%=Results/Phase2/%-short-input-REDUCTION-LLL)
Ph2-REDUCTION-LLL-Long-OutputFiles := $(REDUCTION-LLL-TestSets:%=Results/Phase2/%-long-input-REDUCTION-LLL)

# # Amalgamate the long and short lists into a single list.
# Ph2-REDUCTION-PSLQ-OutputFiles := $(Ph2-REDUCTION-PSLQ-Short-OutputFiles) $(Ph2-REDUCTION-PSLQ-Long-OutputFiles)
# Ph2-REDUCTION-LLL-OutputFiles := $(Ph2-REDUCTION-LLL-Short-OutputFiles) $(Ph2-REDUCTION-LLL-Long-OutputFiles)

# # Amalgamate PSLQ and LLL lists into a single list.
# Ph2-REDUCTION-OutputFiles := $(Ph2-REDUCTION-PSLQ-OutputFiles) $(Ph2-REDUCTION-LLL-OutputFiles)


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
# -= Intermediate Targets
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =-
.PHONY: Ph2-Testing Ph2-APSLQ-Testing Ph2-PSLQ-Testing Ph2-LLL-Testing Ph2-REDUCTION-Testing Ph2-Short-Testing Ph2-Long-Testing Ph2-APSLQ-Short-Testing Ph2-APSLQ-Long-Testing Ph2-PSLQ-Short-Testing Ph2-PSLQ-Long-Testing Ph2-LLL-Short-Testing Ph2-LLL-Long-Testing Ph2-REDUCTION-Short-Testing Ph2-REDUCTION-Long-Testing 

# Target for all Phase 1 testing
Ph2-Testing: Ph2-CLASSICAL-Testing Ph2-REDUCTION-Testing Ph2-APSLQ-Testing

# Targets for testing all short or all long input cases.
Ph2-Short-Testing: Ph2-CLASSICAL-Short-Testing Ph2-REDUCTION-Short-Testing Ph2-APSLQ-Short-Testing

Ph2-Long-Testing: Ph2-CLASSICAL-Long-Testing Ph2-REDUCTION-Long-Testing Ph2-APSLQ-Long-Testing

# Targets for testing all PSLQ related or all LLL related cases.
Ph2-PSLQ-Testing: Ph2-CLASSICAL-PSLQ-Testing Ph2-REDUCTION-LLL-Testing

Ph2-LLL-Testing: Ph2-CLASSICAL-LLL-Testing Ph2-REDUCTION-LLL-Testing

# Targets for testing each conceptual group (classical algebraic relations, REDUCTION method, and Algebraic PSLQ)
Ph2-CLASSICAL-Testing: Ph2-CLASSICAL-PSLQ-Testing Ph2-CLASSICAL-LLL-Testing

Ph2-REDUCTION-Testing: Ph2-REDUCTION-Short-Testing Ph2-REDUCTION-Long-Testing

Ph2-APSLQ-Testing: Ph2-APSLQ-Short-Testing Ph2-APSLQ-Long-Testing

# Targets for testing LLL and PSLQ subcases of the conceptual groups which may use either (classical algebraic relations, and REDUCTION method). 
Ph2-CLASSICAL-PSLQ-Testing: Ph2-CLASSICAL-PSLQ-Short-Testing Ph2-CLASSICAL-PSLQ-Long-Testing

Ph2-CLASSICAL-LLL-Testing: Ph2-CLASSICAL-LLL-Short-Testing Ph2-CLASSICAL-LLL-Long-Testing

Ph2-REDUCTION-PSLQ-Testing: Ph2-REDUCTION-PSLQ-Short-Testing Ph2-REDUCTION-PSLQ-Long-Testing

Ph2-REDUCTION-LLL-Testing: Ph2-REDUCTION-LLL-Short-Testing Ph2-REDUCTION-LLL-Long-Testing

# Targets for testting all short or all long cases for the cases that can be sub-divided into PSLQ or LLL.
Ph2-CLASSICAL-Short-Testing: Ph2-CLASSICAL-PSLQ-Short-Testing Ph2-CLASSICAL-LLL-Short-Testing

Ph2-CLASSICAL-Long-Testing: Ph2-CLASSICAL-PSLQ-Long-Testing Ph2-CLASSICAL-LLL-Long-Testing	

Ph2-REDUCTION-Short-Testing: Ph2-REDUCTION-PSLQ-Short-Testing Ph2-REDUCTION-LLL-Short-Testing

Ph2-REDUCTION-Long-Testing: Ph2-REDUCTION-PSLQ-Long-Testing Ph2-REDUCTION-LLL-Long-Testing

# Targets for the smallest logical groupings.
Ph2-CLASSICAL-PSLQ-Short-Testing: $(Ph2-CLASSICAL-PSLQ-Short-OutputFiles)

Ph2-CLASSICAL-PSLQ-Long-Testing: $(Ph2-CLASSICAL-PSLQ-Long-OutputFiles)

Ph2-CLASSICAL-LLL-Short-Testing: $(Ph2-CLASSICAL-LLL-Short-OutputFiles)

Ph2-CLASSICAL-LLL-Long-Testing: $(Ph2-CLASSICAL-LLL-Long-OutputFiles)

Ph2-REDUCTION-PSLQ-Short-Testing: $(Ph2-REDUCTION-PSLQ-Short-OutputFiles)

Ph2-REDUCTION-PSLQ-Long-Testing: $(Ph2-REDUCTION-PSLQ-Long-OutputFiles)

Ph2-REDUCTION-LLL-Short-Testing: $(Ph2-REDUCTION-LLL-Short-OutputFiles)

Ph2-REDUCTION-LLL-Long-Testing: $(Ph2-REDUCTION-LLL-Long-OutputFiles)

Ph2-APSLQ-Short-Testing: $(Ph2-APSLQ-Short-OutputFiles)

Ph2-APSLQ-Long-Testing: $(Ph2-APSLQ-Long-OutputFiles)

# Set up specific variables as required.
Results/Phase2/%: PHASE=2
Results/Phase2/%: PHASE_DEPENDENCIES=stress-test-PHASE-2.mpl
Results/Phase2/%: INPUT_LENGTH=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-input.*/\1/g')

# Set PHASE_PARAMETER so it can be incorporated into later sets. Allows for inclusion in more specific EXTRA_PARAMETERS..
Results/Phase2/%: PHASE_PARAMETERS=-c 'INPUT_LENGTH:=$(INPUT_LENGTH);'
Results/Phase2/%: EXTRA_PARAMETERS=$(PHASE_PARAMETERS)	

$(Ph2-APSLQ-OutputFiles): GAMMA=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-gamma.*/\1/g')
$(Ph2-APSLQ-OutputFiles): THRESHOLD=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-threshold.*/\1/g')
$(Ph2-APSLQ-OutputFiles): EXTRA_PARAMETERS=$(PHASE_PARAMETERS) -c "Gamma:='$(GAMMA)';" -c 'THRESHOLD:=$(THRESHOLD);' -c 'ITERATIONS:=10000;'
