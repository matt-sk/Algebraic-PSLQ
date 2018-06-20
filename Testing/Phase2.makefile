# Parameters
Thresholds := epsilon epsilon_minus_3 maple
Gammas := gamma_1 2.0 3.0 4.0
Lengths := short long

# Generate the possible output files.
Ph2-APSLQ-OutputFiles := $(APSLQ-TestSets:%=Results/Phase2/%-APSLQ)
Ph2-APSLQ-OutputFiles := $(foreach g,$(Gammas),$(Ph2-APSLQ-OutputFiles:%=%-${g}-gamma))
Ph2-APSLQ-OutputFiles := $(foreach t,$(Thresholds),$(Ph2-APSLQ-OutputFiles:%=%-${t}-threshold))
Ph2-APSLQ-Short-OutputFiles := $(Ph2-APSLQ-OutputFiles:%=%-short-input)
Ph2-APSLQ-Long-OutputFiles := $(Ph2-APSLQ-OutputFiles:%=%-long-input)
Ph2-APSLQ-OutputFiles := $(Ph2-APSLQ-Short-OutputFiles) $(Ph2-APSLQ-Long-OutputFiles)

Ph2-PSLQ-OutputFiles := $(PSLQ-TestSets:%=Results/Phase2/%-PSLQ)
Ph2-PSLQ-Short-OutputFiles := $(Ph2-PSLQ-OutputFiles:%=%-short-input)
Ph2-PSLQ-Long-OutputFiles := $(Ph2-PSLQ-OutputFiles:%=%-long-input)
Ph2-PSLQ-OutputFiles := $(Ph2-PSLQ-Short-OutputFiles) $(Ph2-PSLQ-Long-OutputFiles)

Ph2-LLL-OutputFiles := $(LLL-TestSets:%=Results/Phase2/%-LLL)
Ph2-LLL-Short-OutputFiles := $(Ph2-LLL-OutputFiles:%=%-short-input)
Ph2-LLL-Long-OutputFiles := $(Ph2-LLL-OutputFiles:%=%-long-input)
Ph2-LLL-OutputFiles := $(Ph2-LLL-Short-OutputFiles) $(Ph2-LLL-Long-OutputFiles)

Ph2-REDUCTION-OutputFiles := $(REDUCTION-TestSets:%=Results/Phase2/%-REDUCTION)
Ph2-REDUCTION-Short-OutputFiles := $(Ph2-REDUCTION-OutputFiles:%=%-short-input)
Ph2-REDUCTION-Long-OutputFiles := $(Ph2-REDUCTION-OutputFiles:%=%-long-input)
Ph2-REDUCTION-OutputFiles := $(Ph2-REDUCTION-Short-OutputFiles) $(Ph2-REDUCTION-Long-OutputFiles)

# Rules
.PHONY: Ph2-Testing Ph2-APSLQ-Testing Ph2-PSLQ-Testing Ph2-LLL-Testing Ph2-REDUCTION-Testing Ph2-Short-Testing Ph2-Long-Testing Ph2-APSLQ-Short-Testing Ph2-APSLQ-Long-Testing Ph2-PSLQ-Short-Testing Ph2-PSLQ-Long-Testing Ph2-LLL-Short-Testing Ph2-LLL-Long-Testing Ph2-REDUCTION-Short-Testing Ph2-REDUCTION-Long-Testing 

Ph2-Testing: Ph2-APSLQ-Testing Ph2-PSLQ-Testing Ph2-REDUCTION-Testing

Ph2-APSLQ-Testing: Ph2-APSLQ-Short-Testing Ph2-APSLQ-Long-Testing

Ph2-PSLQ-Testing: Ph2-PSLQ-Short-Testing Ph2-PSLQ-Long-Testing

Ph2-LLL-Testing: Ph2-LLL-Short-Testing Ph2-LLL-Long-Testing

Ph2-REDUCTION-Testing: Ph2-REDUCTION-Short-Testing Ph2-REDUCTION-Long-Testing

Ph2-Short-Testing: Ph2-APSLQ-Short-Testing Ph2-PSLQ-Short-Testing Ph2-LLL-Short-Testing Ph2-REDUCTION-Short-Testing

Ph2-Long-Testing: Ph2-APSLQ-Long-Testing Ph2-PSLQ-Long-Testing Ph2-LLL-Long-Testing Ph2-REDUCTION-Long-Testing

Ph2-APSLQ-Short-Testing: $(Ph2-APSLQ-Short-OutputFiles)

Ph2-APSLQ-Long-Testing: $(Ph2-APSLQ-Long-OutputFiles)

Ph2-PSLQ-Short-Testing: $(Ph2-PSLQ-Short-OutputFiles)

Ph2-PSLQ-Long-Testing: $(Ph2-PSLQ-Long-OutputFiles)

Ph2-LLL-Short-Testing: $(Ph2-LLL-Short-OutputFiles)

Ph2-LLL-Long-Testing: $(Ph2-LLL-Long-OutputFiles)

Ph2-REDUCTION-Short-Testing: $(Ph2-REDUCTION-Short-OutputFiles)

Ph2-REDUCTION-Long-Testing: $(Ph2-REDUCTION-Long-OutputFiles)

Results/Phase2/%: PHASE=2