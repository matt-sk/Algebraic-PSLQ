MAPLE := $(shell which maple)

CONSTANTS := real complex
COEFFICIENTS := large small

# Note that all PSLQ problems are approrpriate for APSLQ, and similarly all APSLQ problems are appropriate for REDUCTION.
# So the %-Affixes (below) are for the exclusive cases (or, should they occur, cases where there is overlap, but )
APSLQ-Affixes=-2 -3 -5 -6 -7 -10 -11
PSLQ-Affixes=-1 1
LLL-Affixes=1
REDUCTION-Affixes=2 3 5 6 7 10 11

APSLQ-TestSets := $(foreach a,$(APSLQ-Affixes),Z[sqrt($(a))])
APSLQ-TestSets := $(foreach c,$(CONSTANTS),$(APSLQ-TestSets:%=%-${c}-constants))
APSLQ-TestSets := $(foreach c,$(COEFFICIENTS),$(APSLQ-TestSets:%=%-${c}-coefficients))

PSLQ-TestSets := $(foreach a,$(PSLQ-Affixes),Z[sqrt(${a})])
PSLQ-TestSets := $(foreach c,$(CONSTANTS),$(PSLQ-TestSets:%=%-${c}-constants))
PSLQ-TestSets := $(foreach c,$(COEFFICIENTS),$(PSLQ-TestSets:%=%-${c}-coefficients))

LLL-TestSets := $(foreach a,$(LLL-Affixes),Z[sqrt(${a})])
LLL-TestSets := $(foreach c,$(CONSTANTS),$(LLL-TestSets:%=%-${c}-constants))
LLL-TestSets := $(foreach c,$(COEFFICIENTS),$(LLL-TestSets:%=%-${c}-coefficients))

# The REDUCTION exclusive problems (i.e., those not also approrpate for APSLQ) are for positive affixes, and so complex constants aren't appropriate.
REDUCTION-TestSets := $(foreach a,$(REDUCTION-Affixes),Z[sqrt(${a})])
REDUCTION-TestSets := $(REDUCTION-TestSets:%=%-real-constants) # Only real constants.
REDUCTION-TestSets := $(foreach c,$(COEFFICIENTS),$(REDUCTION-TestSets:%=%-${c}-coefficients))
REDUCTION-TestSets := $(APSLQ-TestSets) $(REDUCTION-TestSets)

APSLQ-TestSets := $(PSLQ-TestSets) $(APSLQ-TestSets)


# Load Phase 1 specific setup
include Phase1.makefile

# Load Phase 2 specific setup
include Phase2.makefile

# Combine the Phase 1 and Phase 2 output file lists into generic lists.
APSLQ-OutputFiles := $(Ph1-APSLQ-OutputFiles) $(Ph2-APSLQ-OutputFiles)
PSLQ-OutputFiles := $(Ph1-PSLQ-OutputFiles) $(Ph2-PSLQ-OutputFiles)
LLL-OutputFiles := $(Ph1-LLL-OutputFiles) $(Ph2-LLL-OutputFiles)
REDUCTION-OutputFiles := $(Ph1-REDUCTION-OutputFiles) $(Ph2-REDUCTION-OutputFiles)

.SECONDEXPANSION:

.DELETE_ON_ERROR:

.PHONY: all

all: Ph1-Testing Ph2-Testing


# Each APSLQ outpuf file relies on the stress-test-*.mpl files, its base TestFile from the Sets folder, and the APSLQ module.
# Note we need to use the sed command to properly tease out the base file from the output file name.
# Also note that we needed to use secondary expansion to make the dependency work properly.
$(APSLQ-OutputFiles): TESTFILE=$(shell echo "$@" | sed 's/^Results\/Phase[12]\/\(.*\)-APSLQ.*/Sets\/\1/g')
$(APSLQ-OutputFiles): INPUT_LENGTH=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-input.*/\1/g')
$(APSLQ-OutputFiles): GAMMA=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-gamma.*/\1/g')
$(APSLQ-OutputFiles): THRESHOLD=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-threshold.*/\1/g')
$(APSLQ-OutputFiles): stress-test-common.mpl stress-test-APSLQ.mpl $$(TESTFILE) ../../Maple/APSLQ.module.mpl  ../../Maple/APSLQ.mpl  ../../Maple/APSLQ.support.mpl
	$(MAPLE) -q -c 'PHASE:=$(PHASE);' -c 'INPUT:=\"$(TESTFILE)\";' -c 'OUTPUT:=\"$@\";' -c 'INPUT_LENGTH:=$(INPUT_LENGTH);' -c "Gamma:='$(GAMMA)';" -c 'THRESHOLD:=$(THRESHOLD);' -c 'ITERATIONS:=10000;' stress-test-APSLQ.mpl

$(PSLQ-OutputFiles): TESTFILE=$(shell echo "$@" | sed 's/^Results\/Phase[12]\/\(.*\)-PSLQ.*/Sets\/\1/g')
$(PSLQ-OutputFiles): INPUT_LENGTH=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-input.*/\1/g')
$(PSLQ-OutputFiles): stress-test-common.mpl stress-test-PSLQ.mpl $$(TESTFILE)
	$(MAPLE) -q -c 'PHASE:=$(PHASE);' -c 'INPUT:=\"$(TESTFILE)\";' -c 'OUTPUT:=\"$@\";' -c 'INPUT_LENGTH:=$(INPUT_LENGTH);' stress-test-PSLQ.mpl 

$(REDUCTION-OutputFiles): TESTFILE=$(shell echo "$@" | sed 's/^Results\/Phase[12]\/\(.*\)-REDUCTION.*/Sets\/\1/g')
$(REDUCTION-OutputFiles): INPUT_LENGTH=$(shell echo "$@" | sed 's/^.*-\([^-]*\)-input.*/\1/g')
$(REDUCTION-OutputFiles): stress-test-common.mpl stress-test-REDUCTION.mpl $$(TESTFILE)
	$(MAPLE) -q -c 'PHASE:=$(PHASE);' -c 'INPUT:=\"$(TESTFILE)\";' -c 'OUTPUT:=\"$@\";' -c 'INPUT_LENGTH:=$(INPUT_LENGTH);' stress-test-REDUCTION.mpl 
