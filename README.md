# Algebraic PSLQ Testing

Testing of Algebraic PSLQ (equivalently APSLQ): an extension of the PSLQ integer relation finding algorithm to finding relations of algebraic integers for certain complex quadratic extension fields.

This branch contains both an implementation of the extended algorithm (in *Maple*), as well as code to perform (and results of) experimental mathematical testing of the algorithm as published by the author.
The implementation mirrors that found in the master branch.

The results found in this commit are reported in the paper: *“Extending the PSLQ Algorithm to Algebraic Integer Relations”* which has been accepted for publication in the Jon Borwein Commemorative Conference proceedings ([arXiv preprint](https://arxiv.org/abs/1809.06063)).
A link to the published paper will be able to be found in the `README.md` of the master branch as soon as it is available.

## Reproducting Results

In order to reproduce the results you will need the `maple` command line utility. 
It is also highly recommended to have access to the `make` utility available on most unix installations and on OS X. 

Running `make all` will perform all tests (see below for more make targets).

Note that the make utility will decline to run tests if the output files already exist and the files needed to create the output file (the input file, and the test scripts) have not been changed since the output file was created.
In order to avoid this, either delete all files from `Testing/Results/Phase 1/` before running the tests, or run `make` with the `--always-make` option.

If the make utility is not available, then `maple` must be run manually for each combination of approach and valid options.
The general format for the command is `maple -c '<option>=<value>' [-c '<option>=<value>' ... ] stress-test-<approach>.mpl`.
See [Testing Infrastructure](#testing-infrastructure), below for more details (and read the Makefile).

## Testing Infrastructure
Testing scripts can be found in the `Testing/` folder. 
Test sets (input files) are in the `Testing/Sets/` folder.
Output is found in the `Testing/Output/Phase 1/` folder (see [Phases](#phases), below, for more information about the reasoning behind the `Phase 1` folder).

Testing consists of applying each of three different approaches to a collection of test sets. 
The approaches are: *PSLQ*, *REDUCTION*, and *APSLQ*.
The test sets consist of algebraic integer relation problems in quadratic extension fields, and are further sub-divided according to whether the constants are real or complex, and whether the algebraic integers have large or small coefficients.

### Phases

The makefiles and testing scripts refer to *Phase*.
Conceptually, testing is divided into phases; all phases operate on the same test sets, but perform different testing.
Currently, only Phase 1 is implemented, but further phases are planned and the infrastructure is designed to easily allow these new phases to be added in.

Phase 1 is primarily proof-of-concept testing of the computation of algebraic integer relations (the *REDUCTION* and *APSLQ* methods). 
Much of this testing is of different choices of parameters for the *APSLQ* algorithm (primarily gamma values and threshold; see the options table below).
The *PSLQ* method is used as a sanity-check to help make sure the *APSLQ* implementation works correctly when applied to cases that the *PSLQ* algorithm could already handle.

### Test Sets

Input files are grouped into test sets.
Each test set consists of 1000 randomly generated algebraic integer relation problems whose algebraic integer coefficients are all from the same extension field.
The generated algebraic integer relation problems all have a known solution, which is used to check the output of the various approaches.

For each extension field, there are test sets in which the constants (the numbers for which the algebraic integer relations are calculated) are strictly real, and test sets in which the constants are complex.
Furthermore, for each combination of an extension field and a constant field there are test sets for so-called “large” (6 decimal digits) and “small” (1 decimal digit) sized algebraic integers.

The combination of extension field, constant field, and algebraic integer size is indicated in the test set file name.
The format is `Z[sqrt(<D>)]-<field>-constants-<size>-coefficients` where `<D>` is the affix of the extension field (currently only -11,-10,-7,-6,-5,-3,-2,-1,1,2,3,5,6,7,10, or 11 are used), `<field>` is the constant field (real or complex) and `<size>` is the algebraic integer size (large or small).

Note that we use `Z[sqrt(1)]-*` for the usual integer relations for consistency (even though it is unnecessarily verbose mathematically speaking).

Note, also, that not all combinations of extension field and constant field are possible.
If `<D>` is positive, then complex constants are not appropriate.
Every possible combination is accounted for in the test sets.

### Output Files

Output files are located in the `Testing/Output/Phase 1/` folder.
The files are named according to the pattern `<test-set>-<approach>-<options>` where `<test-set>` is the exact name of the test set input file used (without path), and `<approach>` is the approach used (`PSLQ`, `REDUCTION`, or `APSLQ`). 
The `-<options>` portion of the file is only used for the *APSLQ* approach, and is ommited entirely for the other approaches.
For *APSLQ*, `<options>` will be of the form `<gamma>-gamma-<threshold>-threshold` where `<gamma>` is the gamma option, and `<threshold>` is the threshold option (see [Test Scripts](#test-scripts), below, for more details).

Note, however, that not all combinations are possible.
The *PSLQ* method is only applicable for `Z[sqrt(1)]-*` and `Z[sqrt(-1)]-*` files.
The *REDUCTION* method is applicable for all test sets **except** those for which PSLQ may be used.
The *APSLQ* method is only applicable for test sets matching `Z[sqrt(-*)]-*` (i.e., those for which `<D>` is a negative number; see [Test Sets](#test-sets), above).
Furthermore, `gamma_1` (see [Make Targets](#make-targets), below) is not a valid gamma value for test sets matching `Z[sqrt(-5)]-*`, `Z[sqrt(-6)]-*`, or `Z[sqrt(-10)]-*`.

Every possible combination is accounted for in the results (and is calculated in the Makefile).

### Make targets
Each output file is its own target (as is typical for `make`).

Additionally, the following targets are available to perform the indicated groups of testing

Target|Tests
--|--
`all`|Run all tests
`Ph1-Testing`|Run all Phase 1 tests (currently equivalent to `all`; see Phases section)
`Ph1-PSLQ-Testing`|Run all Phase 1 tests for the *PSLQ* method.
`Ph1-REDUCTION-Testing`|Run all Phase 1 tests for the *REDUCTION* method.
`Ph1-APSLQ-Testing`|Run all Phase 1 tests for the *APSLQ* method.

### Test Scripts
The *Maple* test scripts, found in the `Testing/` folder, are the files matching the `stress-test-*.mpl` file glob.
Each approach (*PSLQ*, *REDUCTION*, and *APSLQ*) has a corresponding test script which is the file given to *Maple* at the command line.
These files call `stress-test-common.mpl` which in turn calls `stress-test-PHASE-1.mpl`.
Options are specified by setting *Maple* variables using the `-c` command line parameter at the command line.

It is `stress-test-PHASE-1.mpl` that performs the actual work of opening the test set (i.e., input file), setting the appropriate parameters, extracting and testings each test instance, and outputting the results to the output file.
Generality is achieved by using `SETUP` `PRECHECK`, `TEST`, `CHECK`, `POSTCHECK`, `EXTRAOUTPUT`, and `TIDYUP` functions which `stress-test-PHASE-1.mpl` expects to already be defined appropriately prior to it being called.

File|Purpose|Options
:--:|:--|:--
`stress-test-PHASE-1.mpl`|Runs the actual testing.
`stress-test-common.mpl`|Defines defaults for any of the `SETUP`, `PRECHECK`, `TEST`, `CHECK`, `POSTCHECK`, `EXTRAOUTPUT`, and `TIDYUP`functions not already defined.|`INPUT`,`OUTPUT`, `PHASE`
`stress-test-PSLQ.mpl`|Define `TEST` function for testing of integer relations able to be handled by the *PSLQ* algorithm.
`stress-test-REDUCTION.mpl`|Define `TEST`, `POSTCHECK`, and `EXTRAOUTPUT` functions for testing of algebraic integer relations using the *REDUCTION* method (reducing to an integer relation suitable for the *PSLQ* algorithm).
`stress-test-APSLQ.mpl`|Define `SETUP`, `TEST`, `PRECHECK`, `EXTRAOUTPUT` and `TIDYUP` function for testing of algebraic integer relations able to be handled by the *APSLQ* algorithm.|`GAMMA`, `THRESHOLD`, `ITERATIONS`, `PROFILE`

The options are as follows:

Option|Needed by|Details|Default
:--:|:--|:--|:--
`INPUT`|`stress-test-common.mpl`|Name (and path) of the test set (input file) to be read and tested. Should be of type `string`.
`OUTPUT`|`stress-test-common.mpl`|Name (and path) of the output file that will store the results of the testing. Should be of type `string`.
`PHASE`|`stress-test-common.mpl`|The testing phase to be run. Must be `1`.
`GAMMA`|`stress-test-APSLQ.mpl`|The gamma parameter to be used in the *APSLQ* algorithm. Should be either the literal `gamma_1` or any expression of `realcons` type.| `2/sqrt(3)`
`THRESHOLD`|`stress-test-APSLQ.mpl`|Determines the value below which the *APSLQ* algorithm will consider a floating point number to be 0 for the purposes of detecting an algebraic integer relation. Should be either one of the literals `epsilon`, `epsilon_minus_3`, `epsilon_minus_5`, `maple`, otherwise a floating point value between 0 and 1. If a floating point number then the value is calculated as `10^(-THRESHOLD*P)` where `P` is the decimal digit precision of the computation.|`0.24`
`ITERATIONS`|`stress-test-APSLQ.mpl`|The maximum number of iterations the *APSLQ* algorithm may perform. If the algorithm does not terminate before this many iterations are performed, it terminates with a `FAIL` result. Should be an expression of type `posint`.|`1000`
`PROFILE`|`stress-test-APSLQ.mpl`|Indicate whether or not the *APSLQ* implementation should be profiled for performance. When set to true, the profiling information is also written to the output. Should be an expression of type `truefalse`.|`false`
