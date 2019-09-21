#!/bin/bash

# Argumentis should be input files. Multiple may be given.
# Each argument one will produce a .csv file of precision and timing results for all output files coming from that input file.

# Note that this only makes sense for Phase2 testing.

# Create a temporary folder to store files in
TEMPFOLDER=$(mktemp -d)

# Create some FIFO's that will be used for later processing
mkfifo ${TEMPFOLDER}/TIMING_DATA
mkfifo ${TEMPFOLDER}/PRECISION_DATA

# Set a trap to remove any temp files that have been created during the processing.
# Using a trap means that temp files are deleted even if the script ends prematurely.
function cleanup {
	if [ -d "${TEMPFOLDER}" ]; then
		rm -Rf ${TEMPFOLDER}
	fi
}

function CreateNewTEMPFILE {
	TEMPFILE=$(mktemp ${TEMPFOLDER}/XXXX)
}

trap cleanup EXIT

# Canonical list of computation methods (thesse correspond to testing output files).
METHODS=(PSLQ LLL APSLQ-gamma_1-gamma-epsilon-threshold APSLQ-2.0-gamma-epsilon-threshold APSLQ-3.0-gamma-epsilon-threshold APSLQ-4.0-gamma-epsilon-threshold)

for INPUT_FILE in "$@";  do 
	# Extract indexing information and digit counts for the problems from the input file
	CreateNewTEMPFILE
	ID_AND_COUNT_FILE=${TEMPFILE}

	# Extract  Id, Digit Count (Max), and Digit Count (Total) for the input file.
	maple -q -c "INPUT_FILENAME := \\\"${INPUT_FILE}\\\";" precision-and-timing-results.mpl >> ${ID_AND_COUNT_FILE}

	# Extract a second copy of the ID column to append after sorting (later)
	CreateNewTEMPFILE
	INDEX_FILE=${TEMPFILE}
	cut -d, -f1 ${ID_AND_COUNT_FILE} > ${INDEX_FILE}

	# There will always be a single PSLQ file (either -CLASSICAL-PSLQ or -REDUCTION-PSLQ)
	BASEFILE=$(basename ${INPUT_FILE})
	PSLQ_FILES=$(find Phase2 | grep -F ${BASEFILE} | grep "PSLQ$")

	for PSLQ_FILE in ${PSLQ_FILES}; do
		# Extract the classical integer relation method (either CLASSICAL, or REDUCTION) from the PSLQ file name.
		# This should be the same for each PSLQ_FILE, but we'll recalculate it anyway)
		CLASSICAL_OR_REDUCTION=$(echo ${PSLQ_FILE} | sed 's/.*-\([^-]*\)-PSLQ$/\1/') 

		# Re-define BASEFILE to refer to the base PSLQ output file, stripped of the -METHOD-PSLQ.
		BASEFILE=$(echo ${PSLQ_FILE} | sed 's/\(.*\)-[^-]*-PSLQ$/\1/')

		# We extract the theoretical precision information.
		CreateNewTEMPFILE
		HEADER="Original Id,Digit Count (Max),Digit Count (Total),Theoretical Min Precision"
		PASTEFILES="${ID_AND_COUNT_FILE} ${TEMPFILE}"
		sed 's/^.*, TheoreticalMinPrecision = \([0-9]*\),.*$/\1/g' ${PSLQ_FILE} > ${TEMPFILE};

		# For each method we extract the runtime precision used, and time taken from the corresponding results. 
		# Some of these won't exist, in which case We simply produce empty colmns for the CSV data.
		for METHOD in ${METHODS[@]}; do
			# Find the output file (from testing) corresponding to this method.
			if [[ "${METHOD}" == "APSLQ-"* ]]; then
				RESULTS_FILE="${BASEFILE}-${METHOD}"
			else
				RESULTS_FILE="${BASEFILE}-${CLASSICAL_OR_REDUCTION}-${METHOD}"
			fi

			# Create a temporary file 
			CreateNewTEMPFILE
			PASTEFILES="${PASTEFILES} ${TEMPFILE}"

			# Produce the data columns for the CSV file. (Includes tidying up the METHOD name to make a neater heading).
			TIDIED_METHOD_NAME="$(echo ${METHOD} | sed 's/-epsilon-threshold$//')"
			HEADER="${HEADER},${TIDIED_METHOD_NAME} Calculation Time,${TIDIED_METHOD_NAME} Precision"
			if [ -r "${RESULTS_FILE}" ]; then
				# Create each column separately (in the background), and write to a FIFO
				# We remove any incomplete lines first before processing.
				sed -e '/[^]][^)]$/d' -e 's/^.* CalculationTime = \([^,]*\).*$/\1/' ${RESULTS_FILE} > $TEMPFOLDER/TIMING_DATA &
				sed -e '/[^]][^)]$/d' -e 's/^.* PrecisionUsed = \([^,]*\).*$/\1/' ${RESULTS_FILE} > $TEMPFOLDER/PRECISION_DATA &

				# Combine the columns in the FIFO's into CSV columns stored in ${TEMPFILE}
				paste -d, ${TEMPFOLDER}/TIMING_DATA ${TEMPFOLDER}/PRECISION_DATA > ${TEMPFILE}
			else
				# Create a CSV file of two empty columns.
				sed 's/^.*$/,/' ${PSLQ_FILE} > ${TEMPFILE} 
			fi

			# It's possible that the contents of the file were incomplete. Pad any files with empty column information.
			LINECOUNT=$(wc -l ${TEMPFILE} | awk '{print $1}')
			if [ ${LINECOUNT} -lt 1000 ]; then
				# Print out two empty rows (",\n") enough times to bring the file to 1000 rows
				printf ",\n%.0s" $(seq ${LINECOUNT} 999) >> ${TEMPFILE}
			fi

		done # END OF PROCESSING FOR THIS METHOD

		# Collate the columns, sort, then append the indices. (Sort by Theoretical Min Precision, then Digit Count Total).
		CreateNewTEMPFILE
		paste -d, ${PASTEFILES} | sort --numeric-sort --field-separator=',' --key=4,4 --key=3,3 > ${TEMPFILE}

		# Write the output file, appending the header. (Note that ${TEMPFILE} is currently the sorted output from above)
		CSV_FILE=$(basename ${BASEFILE}).csv
		echo Outputting to ${CSV_FILE}

		echo "Index,${HEADER}" > ${CSV_FILE}
		paste -d, ${INDEX_FILE} ${TEMPFILE}  >> ${CSV_FILE}

	done

done
