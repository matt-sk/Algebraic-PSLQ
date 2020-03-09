#!/bin/bash

# Arguments should be a list of affixes (numbers). 
# Each $n will be used to calculate results for Z[sqrt($n)] (using all available test sets for this affix)

get_counts( ) {
	local RESULTSFILE=${1}

	BADCOUNT=$(grep ', Result = BAD' ${RESULTSFILE} | wc -l)
	FAILCOUNT=$(grep ', Result = FAIL' ${RESULTSFILE} | wc -l)
	UNEXPECTEDCOUNT=$(grep ', Result = UNEXPECTED' ${RESULTSFILE} | wc -l)
	GOODCOUNT=$(grep ', Result = GOOD' ${RESULTSFILE} | wc -l)
}

# An exhaustive list of all methods in the order they should appear in tables.
# Note that not all of these will exist for any given base file. Any non-existant ones will simply be skipped.
# The resulting order will make sense for the AFFIX.
METHODS="CLASSICAL-PSLQ CLASSICAL-LLL REDUCTION-PSLQ REDUCTION-LLL APSLQ-gamma_1-gamma-epsilon-threshold APSLQ-2.0-gamma-epsilon-threshold APSLQ-3.0-gamma-epsilon-threshold APSLQ-4.0-gamma-epsilon-threshold"

echo FIELD CONSTANTS IOTA ${METHODS} | sed 's/ /, /g'

for INPUT_LENGTH in short long; do
	echo "${INPUT_LENGTH} Input"
	APPENDIX="${INPUT_LENGTH}-input"

	for AFFIX in "$@"; do
		BASENAME="Z[sqrt(${AFFIX})]"

		for CONSTANTS in real complex; do
			# Work out the latex representation of the constant set.
			case "${CONSTANTS}" in 
				"real")		CONST_SET='\(C_{\reals}\)';;
				"complex")	CONST_SET='\(C_{\complexes}\)';;
				*)				CONST_SET="N/A";;
			esac

			for COEFFICIENTS in small large; do
				# Construct the input file name.
				INPUT_FILE="${BASENAME}-${CONSTANTS}-constants-${COEFFICIENTS}-coefficients"

				# If the input file doesn't exist, stop processing and move to the next item in the loop.
				[ -r "../Sets/${INPUT_FILE}" ] || continue

				# Work out the iota value for this coefficient size.
				case "${COEFFICIENTS}" in 
					"large")	IOTA=6;;
					"small")	IOTA=1;; 
					*)			IOTA="N/A";;
				esac

				printf "\Qext{\sqrt{%s}} & %s & \(%s\) &" ${AFFIX} ${CONST_SET} ${IOTA}

				for METHOD in $METHODS; do
					if [ -r Phase2/${INPUT_FILE}-${APPENDIX}-${METHOD} ]; then
						get_counts Phase2/${INPUT_FILE}-${APPENDIX}-${METHOD}

						printf "& %d&%d&%d&%d " ${GOODCOUNT} ${UNEXPECTEDCOUNT} ${BADCOUNT} ${FAILCOUNT}
					else
						printf "& &&& "
					fi
				done

				# End the current line (both of the output of this script, and also in LaTeX).
				echo '\\'
			done
		done
	done
done
