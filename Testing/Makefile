MAPLE := $(shell which maple)

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
#  = Generate lists of TestSets appropriate to each of the basic tests: PSLQ, REDUCTION, APSLQ             = 
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
CONSTANTS := real complex
COEFFICIENTS := large small

# CLASSICAL Test sets.
CLASSICAL-Real-Affixes := 1
CLASSICAL-Complex-Affixes := -1

CLASSICAL-Real-TestSets := $(foreach a,$(CLASSICAL-Real-Affixes),Z[sqrt($(a))])
CLASSICAL-Real-TestSets := $(CLASSICAL-Real-TestSets:%=%-real-constants)
CLASSICAL-Real-TestSets := $(foreach c,$(COEFFICIENTS),$(CLASSICAL-Real-TestSets:%=%-${c}-coefficients))

CLASSICAL-Complex-TestSets := $(foreach a,$(CLASSICAL-Complex-Affixes),Z[sqrt($(a))])
CLASSICAL-Complex-TestSets := $(foreach c,$(CONSTANTS),$(CLASSICAL-Complex-TestSets:%=%-${c}-constants))
CLASSICAL-Complex-TestSets := $(foreach c,$(COEFFICIENTS),$(CLASSICAL-Complex-TestSets:%=%-${c}-coefficients))

CLASSICAL-PSLQ-TestSets := $(CLASSICAL-Real-TestSets) $(CLASSICAL-Complex-TestSets)
CLASSICAL-LLL-TestSets := $(CLASSICAL-Real-TestSets)

#  = REDUCTION Test Sets                                                                                   =
REDUCTION-Real-Affixes := 2 3 5 6 7 10 11
REDUCTION-Complex-Affixes := -2 -3 -5 -6 -7 -10 -11

REDUCTION-Real-TestSets := $(foreach a,$(REDUCTION-Real-Affixes),Z[sqrt($(a))])
REDUCTION-Real-TestSets := $(REDUCTION-Real-TestSets:%=%-real-constants)
REDUCTION-Real-TestSets := $(foreach c,$(COEFFICIENTS),$(REDUCTION-Real-TestSets:%=%-${c}-coefficients))

REDUCTION-Complex-TestSets := $(foreach a,$(REDUCTION-Complex-Affixes),Z[sqrt($(a))])
REDUCTION-Complex-TestSets := $(foreach c,$(CONSTANTS),$(REDUCTION-Complex-TestSets:%=%-${c}-constants))
REDUCTION-Complex-TestSets := $(foreach c,$(COEFFICIENTS),$(REDUCTION-Complex-TestSets:%=%-${c}-coefficients))

REDUCTION-PSLQ-TestSets := $(REDUCTION-Real-TestSets) $(REDUCTION-Complex-TestSets)
REDUCTION-LLL-TestSets := $(REDUCTION-Real-TestSets)

#  = APSLQ Test Sets (all are complex except for the usual real case)                                      =
APSLQ-gamma_1-Affixes := -1 -2 -3 -7 -11
APSLQ-no_gamma_1-Affixes :=  -5 -6 -10 

APSLQ-gamma_1-TestSets := $(foreach a,$(APSLQ-gamma_1-Affixes),Z[sqrt($(a))])
APSLQ-gamma_1-TestSets := $(foreach c,$(CONSTANTS),$(APSLQ-gamma_1-TestSets:%=%-${c}-constants))
APSLQ-gamma_1-TestSets := $(foreach c,$(COEFFICIENTS),$(APSLQ-gamma_1-TestSets:%=%-${c}-coefficients))

#  = Special case for the unique real-only case that APSLQ can handle                                      =
APSLQ-gamma_1-TestSets := Z[sqrt(1)]-real-constants-small-coefficients Z[sqrt(1)]-real-constants-large-coefficients $(APSLQ-gamma_1-TestSets)

APSLQ-no_gamma_1-TestSets := $(foreach a,$(APSLQ-no_gamma_1-Affixes),Z[sqrt($(a))])
APSLQ-no_gamma_1-TestSets := $(foreach c,$(CONSTANTS),$(APSLQ-no_gamma_1-TestSets:%=%-${c}-constants))
APSLQ-no_gamma_1-TestSets := $(foreach c,$(COEFFICIENTS),$(APSLQ-no_gamma_1-TestSets:%=%-${c}-coefficients))
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-


# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
#  = Load Phase 1 specific setup                                                                           =
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
include Phase1.makefile
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
#  = Load Phase 2 specific setup                                                                           =
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
include Phase2.makefile
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
#  = Combine the Phase 1 and Phase 2 output file lists into generic lists                                  =
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
APSLQ-OutputFiles := $(Ph1-APSLQ-OutputFiles) $(Ph2-APSLQ-OutputFiles)
PSLQ-OutputFiles := $(Ph1-PSLQ-OutputFiles) $(Ph2-PSLQ-OutputFiles)
REDUCTION-OutputFiles := $(Ph1-REDUCTION-OutputFiles) $(Ph2-REDUCTION-OutputFiles)
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-

# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
#  = Targets                                                                                               =
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
.SECONDEXPANSION:

.DELETE_ON_ERROR:

.PHONY: all

all: Ph1-Testing Ph2-Testing

#  = All output files rely on its base TestFile (from Sets/), and stress-test-common.mpl.                  =
#  = Note we need to use the sed command to properly tease out the base file from the output file name.    =
#  = Also note that we needed to use secondary expansion to make the dependency work properly.             =
Results/%: TESTFILE=$(shell echo "$@" | sed 's/^Results\/Phase[^\/]*\/.*\(Z.*-coefficients\).*/Sets\/\1/g')
Results/%: GENERAL_DEPENDENCIES=$(TESTFILE) stress-test-common.mpl
Results/%: MAPLE_ARGUMENTS=-q -c 'PHASE:=$(PHASE);' -c 'INPUT:=\"$(TESTFILE)\";' -c 'OUTPUT:=\"$@\";' $(EXTRA_PARAMETERS)

#  = APSLQ output files rely on stress-test-APSLQ and the APSLQ.module.mpl file (in addition to the general requirements).
#  = Note that we cannot use a %-rule to uniquely identify APSLQ output files, so we use $(APSLQ-OutputFiles) instead.
$(APSLQ-OutputFiles): $$(GENERAL_DEPENDENCIES) $$(PHASE_DEPENDENCIES) stress-test-APSLQ.mpl ../Maple/APSLQ.module.mpl
	${MAPLE} ${MAPLE_ARGUMENTS} stress-test-APSLQ.mpl

#  = PSLQ output files rely only on stress-test-PSLQ (in addition to the general requirements).            =
Results/%-CLASSICAL-PSLQ: $$(GENERAL_DEPENDENCIES) $$(PHASE_DEPENDENCIES) stress-test-CLASSICAL_INTEGER_RELATION.mpl IntegerRelationFunctions.mpl
	${MAPLE} ${MAPLE_ARGUMENTS} -c 'INTEGER_RELATION_FUNCTION := PSLQ;' stress-test-CLASSICAL_INTEGER_RELATION.mpl

Results/%-CLASSICAL-LLL: $$(GENERAL_DEPENDENCIES) $$(PHASE_DEPENDENCIES) stress-test-CLASSICAL_INTEGER_RELATION.mpl IntegerRelationFunctions.mpl
	${MAPLE} ${MAPLE_ARGUMENTS} -c 'INTEGER_RELATION_FUNCTION := LLL;' stress-test-CLASSICAL_INTEGER_RELATION.mpl

#  = REDUCTION output files rely only on stress-test-REDUCTION (in addition to the general requirements).  =
Results/%-REDUCTION-PSLQ: $$(GENERAL_DEPENDENCIES) $$(PHASE_DEPENDENCIES) stress-test-REDUCTION.mpl IntegerRelationFunctions.mpl
	${MAPLE} ${MAPLE_ARGUMENTS} -c 'INTEGER_RELATION_FUNCTION := PSLQ;' stress-test-REDUCTION.mpl

Results/%-REDUCTION-LLL: $$(GENERAL_DEPENDENCIES) $$(PHASE_DEPENDENCIES) stress-test-REDUCTION.mpl IntegerRelationFunctions.mpl
	${MAPLE} ${MAPLE_ARGUMENTS} -c 'INTEGER_RELATION_FUNCTION := LLL;' stress-test-REDUCTION.mpl
# -= =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= =-
