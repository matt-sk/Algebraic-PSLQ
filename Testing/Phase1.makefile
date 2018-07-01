# Parameters
Thresholds := epsilon epsilon_minus_3 maple
Gammas := gamma_1 2.0 3.0

# Generate the possible output files.
Ph1-APSLQ-OutputFiles := $(APSLQ-TestSets:%=Results/Phase1/%-APSLQ)
Ph1-APSLQ-OutputFiles := $(foreach g,$(Gammas),$(Ph1-APSLQ-OutputFiles:%=%-${g}-gamma))
Ph1-APSLQ-OutputFiles := $(foreach t,$(Thresholds),$(Ph1-APSLQ-OutputFiles:%=%-${t}-threshold))

Ph1-PSLQ-OutputFiles := $(PSLQ-TestSets:%=Results/Phase1/%-PSLQ)

Ph1-REDUCTION-OutputFiles := $(REDUCTION-TestSets:%=Results/Phase1/%-REDUCTION)

# Rules
.PHONY: all Ph1-Testing Ph1-APSLQ-Testing Ph1-PSLQ-Testing Ph1-REDUCTION-Testing 

Ph1-Testing: Ph1-APSLQ-Testing Ph1-PSLQ-Testing Ph1-REDUCTION-Testing

Ph1-APSLQ-Testing: $(Ph1-APSLQ-OutputFiles)

Ph1-PSLQ-Testing: $(Ph1-PSLQ-OutputFiles)

Ph1-REDUCTION-Testing: $(Ph1-REDUCTION-OutputFiles)

Results/Phase1/%: PHASE=1
