# Integer Relation Testing

Testing of Integer Relation calculation algorithms including PSLQ, LLL, and Algebraic PSLQ (equivalently APSLQ): an extension of the PSLQ integer relation finding algorithm to finding relations of complex quadratic integers.

This branch contains both an implementation of the APSLQ algorithm (in *Maple*), as well as code to perform (and the results of) experimental mathematical testing of all the above algorithms as published by the author.
The APSLQ implementation mirrors that found in the master branch.

The results found in this commit are transnational between those reported in the paper: *“Extending the PSLQ Algorithm to Algebraic Integer Relations”* which is published in the Jon Borwein Commemorative Conference proceedings ([DOI: 10.1007/978-3-030-36568-4_26](https://doi.org/10.1007/978-3-030-36568-4_26), or [arXiv preprint](https://arxiv.org/abs/1809.06063)) and the author's soon to be submitted Ph.D thesis “Some Iterative Algorithms in Experimental Mathematics”.
A link to the thesis will be provided if and when it is accepted.

## Reproducing Results

In order to reproduce the results you will need the `maple` command line utility.
It is also highly recommended to have access to the `make` utility available on most unix installations and on OS X.

Running `make all` will perform all tests (see below for more make targets).

Note that the make utility will decline to run tests if the output files already exist and the files needed to create the output file (the input file, and the test scripts) have not been changed since the output file was created.
In order to avoid this, either delete all files from `Testing/Results/Phase 1/` and/or `Testing/Results/Phase 2/` folders (as appropriate) before running the tests, or run `make` with the `--always-make` option.

If the make utility is not available, then `maple` must be run manually for each combination of approach and valid options.
See [Testing Infrastructure](#testing-infrastructure), below for more details (and read the Makefile).

## Testing Infrastructure
Testing scripts can be found in the `Testing/` folder.
Test sets (input files) are in the `Testing/Sets/` folder.
Output is found in the `Testing/Output/Phase 1/` and `Testing/Output/Phase 2/` folders (see [Phases](#phases), below, for more information about the reasoning behind the phases).

The test sets consist of algebraic integer relation problems in quadratic extension fields, and are further sub-divided according to whether the constants are real or complex, and whether the algebraic integers have large or small coefficients.

Testing consists of applying each of three different approaches to a collection of test sets.
The approaches are: *CLASSICAL*, *REDUCTION*, and *APSLQ*.
Both *CLASSICAL* and *REDUCTION* make use of either the *PSLQ* or *LLL* algorithms as specified by the user.

The *PSLQ* and *LLL* algorithms behave as follows:
* The *CLASSICAL* method uses the *PSLQ* or *LLL* algorithm directly for classical integer relation problems.
In the case of *LLL* “directly” in this case involves reducing the integer relation problem to a real lattice reduction problem.
* The *REDUCTION* uses the *PSLQ* or *LLL* algorithms for solving quadratic integer relation problems by reducing them to another problem.
	* In the case of *PSLQ*, the quadratic integer relation problem is reduced to a classical integer relation problem which is then solved.
	* In the case of *LLL*, real quadratic integer problems are treated the same as for the *PSLQ* algorithm (but using *LLL* instead).
	For complex quadratic integer problems, the problem is reduced to a particular real lattice reduction problem (different to that of the *CLASSICAL* case) which is then solved.

### Phases

The makefiles and testing scripts refer to *Phase*.
Conceptually, testing is divided into phases; all phases operate on the same test sets, but perform different testing.
Currently, two Phases are implemented, but Phase 2 is the primarily testing being performed at the time of writing..

Phase 1 is the testing used for the results given in the paper “Extending the PSLQ Algorithm to Algebraic Integer Relations”.
It is primarily proof-of-concept testing of the computation of algebraic integer relations (the *REDUCTION* and *APSLQ* methods).
Much of this testing is of different choices of parameters for the *APSLQ* algorithm (primarily gamma values and threshold; see the options table below).

Phase 2 is the testing used exploration in the author's Ph.D thesis “Some Iterative Algorithms in Experimental Mathematics”.
It explores the precision requirements of the algorithms, and the viability of the algorithms in the presence of unnecessary extra information.
In the case of *APSLQ* multiple values of gamma (and consequently their relationship to required precision) are tested, and all testing is performed using a threshold of machine epsilon (10<sup> -(*p*-1)</sup> for a computation of *p* decimal digits of precision).

In both Phases the *CLASSICAL* method is used as a sanity-check to help make sure the *APSLQ* implementation works correctly when applied to cases that the *PSLQ* algorithm could already handle.

Phase specific testing is found in the `Phase*.makefile` and `stress-test-PHASE-*.mpl` files.
All code not in these files is shared between all phases.

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

Output files are located in the `Testing/Output/Phase 1/` or `Testing/Output/Phase 2/` folders as appropriate.
The files are named according to the pattern `<test-set>-<method>-<options>` where `<test-set>` is the exact name of the test set input file used (without path), and `<method>` is the method used (`PSLQ`, `REDUCTION`, or `APSLQ`).
The `-<options>` portion of the file gives extra information about the particular invocation of the method in question.
For *CLASSICAL* or *REDUCTION*, `<options>` will be either `PSLQ` or `LLL`.
For *APSLQ*, `<options>` will be of the form `<gamma>-gamma-<threshold>-threshold` where `<gamma>` is the gamma option, and `<threshold>` is the threshold option (see [Test Scripts](#test-scripts), below, for more details).

Note, however, that not all combinations are possible.
The *CLASSICAL* method is only applicable for `Z[sqrt(1)]-*` and `Z[sqrt(-1)]-*` files.
The *REDUCTION* method is applicable for all test sets **except** those for which PSLQ may be used.
The *APSLQ* method is only applicable for test sets matching `Z[sqrt(-*)]-*` (i.e., those for which `<D>` is a negative number; see [Test Sets](#test-sets), above).
Furthermore, `gamma_1` (see [Make Targets](#make-targets), below) is not a valid gamma value for test sets matching `Z[sqrt(-5)]-*`, `Z[sqrt(-6)]-*`, or `Z[sqrt(-10)]-*`.

Every possible combination is accounted for in the results (and is calculated in the Makefile).

### Make Targets
Each output file is its own target (as is typical for `make`).

Additionally, the following targets are available to perform the indicated groups of testing

Target|Tests
--|--
`all`|Run all tests
`Ph1-Testing`|Run all Phase 1 tests.
`Ph2-Testing`|Run all Phase 2 tests.

The following targets may be prefixed with `Ph1-` or `Ph2-` to restrict the testing to Phase 1 or Phase 2 respectively.
If no prefix is given, then the appropriate tests from both phases are run.
Additionally, in the case of Phase 2 only (i.e., with a `Ph2-` prefix) `Testing` may be replaced with `Short-Testing` or `Long-Testing` to further restrict the testing cases to those of short or long input respectively.

Target|Tests
--|--
`LLL-Testing`|Run all tests involving the *LLL* algorithm.
`PSLQ-Testing`|Run all tests involving the *PSLQ* algorithm.
`CLASSICAL-Testing`|Run all tests using the *CLASSICAL* method.
`REDUCTION-Testing`|Run all tests using the *REDUCTION* method.
`APSLQ-Testing`|Run all tests using the *APSLQ* method.
`CLASSICAL-LLL-Testing`|Run all tests using the *CLASSICAL* method together with the *LLL* algorithm.
`CLASSICAL-PSLQ-Testing`|Run all tests using the *CLASSICAL* method together with the *PSLQ* algorithm.
`REDUCTION-LLL-Testing`|Run all tests using the *REDUCTION* method together with the *LLL* algorithm.
`REDUCTION-PSLQ-Testing`|Run all tests using the *REDUCTION* method together with the *PSLQ* algorithm.

### Test Scripts
The *Maple* test scripts, found in the `Testing/` folder, are the files matching the `stress-test-*.mpl` file glob.
Each method (*CLASSICAL*, *REDUCTION*, and *APSLQ*) has a corresponding test script which is the file given to *Maple* at the command line.
These files call `stress-test-common.mpl` which in turn calls `stress-test-PHASE-1.mpl` or `stress-test-PHASE-2.mpl` as appropriate.
Options are specified by setting *Maple* variables using the `-c` command line parameter at the command line.

It is `stress-test-PHASE-*.mpl` that performs the actual work of opening the test set (i.e., input file), setting the appropriate parameters, extracting and testing each test instance, and outputting the results to the output file.
Generality is achieved by using `SETUP` `PRECHECK`, `TEST`, `CHECK`, `POSTCHECK`, and `TIDYUP` functions which `stress-test-PHASE-*.mpl` expects to already be defined appropriately prior to it being called.

Functions return a pair of result (whatever is appropriate for the function) and a list of `key = <value>` pairs. The latter is amalgamated by each call into its own `key = <value>` list that is, in turn.
In this way information to be written to the output file may be included at any stage with a predictable order.

File|Purpose|Options
:--:|:--|:--
`stress-test-PHASE-*.mpl`|Runs the actual testing.
`stress-test-common.mpl`|Defines defaults for any of the `TEST`, `SETUP`, `PRECHECK`, `POSTCHECK`, and `TIDYUP` functions not already defined. Additionally defines `CHECK`, `CALCULATE_TEST_PROBLEM` and `PROCESS_LINE` functions |`INPUT`,`OUTPUT`, `PHASE`
`stress-test-CLASSICAL_INTEGER_RELATION.mpl`|Define `SETUP` and `TEST` functions for testing of integer relations able to be handled by the *CLASSICAL* method.|`INTEGER_RELATION_FUNCTION`
`stress-test-REDUCTION.mpl`|Define `SETUP`, `TEST`, and `PRECHECK` functions for testing of algebraic integer relations using the *REDUCTION* method. Additionally defines `COMPLEX_QUADRATIC_PSLQ_PRECHECK_TRANSFORM`, `DIRECT_TEST` and `REDUCTION_TEST` which is aliased to `PRECHECK` or `TEST` as appropriate. Defines function for type checking Gaussian integers and quadratic complex quadratic integers.|`INTEGER_RELATION_FUNCTION`
`stress-test-APSLQ.mpl`|Define `SETUP`, `TEST`, `PRECHECK`, and `TIDYUP` function for testing of algebraic integer relations able to be handled by the *APSLQ* algorithm.|`Gamma`, `THRESHOLD`, `ITERATIONS`, `PROFILE`
`IntegerRelationFunctions.mpl`|Defines functions for computing integer relation problems with directly with `PSLQ` or `LLL`. Defines functions `LLL_INTEGER_RELATION` and `PSLQ_INTEGER_RELAION`. The former is aliased to either `LLL_INTEGER_RELATION_REAL_CLASSICAL` or `LLL_INTEGER_RELATION_COMPLEX_ALGEBRAIC` as appropriate, which in turn both use the worker function `DO_LLL_INTEGER_RELATION`.|`INTEGER_RELATION_FUNCTION`

The options are as follows:

Option|Needed by|Details|Default
:--:|:--|:--|:--
`INPUT`|`stress-test-common.mpl`|Name (and path) of the test set (input file) to be read and tested. Should be of type `string`.
`OUTPUT`|`stress-test-common.mpl`|Name (and path) of the output file that will store the results of the testing. Should be of type `string`.
`PHASE`|`stress-test-common.mpl`|The testing phase to be run. Must be `1`.
`Gamma`|`stress-test-APSLQ.mpl`|The gamma parameter to be used in the *APSLQ* algorithm. Should be either the literal `gamma_1` or any expression of `realcons` type.| `2/sqrt(3)`
`THRESHOLD`|`stress-test-APSLQ.mpl`|Determines the value below which the *APSLQ* algorithm will consider a floating point number to be 0 for the purposes of detecting an algebraic integer relation. Should be either one of the literals `epsilon`, `epsilon_minus_3`, `epsilon_minus_5`, `maple`, otherwise a floating point value between 0 and 1. If a floating point number then the value is calculated as `10^(-THRESHOLD*P)` where `P` is the decimal digit precision of the computation.|`0.24`
`ITERATIONS`|`stress-test-APSLQ.mpl`|The maximum number of iterations the *APSLQ* algorithm may perform. If the algorithm does not terminate before this many iterations are performed, it terminates with a `FAIL` result. Should be an expression of type `posint`.|`1000`
`PROFILE`|`stress-test-APSLQ.mpl`|Indicate whether or not the *APSLQ* implementation should be profiled for performance. When set to true, the profiling information is also written to the output. Should be an expression of type `truefalse`.|`false`
`INTEGER_RELATION_FUNCTION`|`stress-test-CLASSICAL_INTEGER_RELATION.mpl` and `stress-test-REDUCTION.mpl`|Indicate whether to use *PSLQ* or *LLL* algorithm for the method in question. Must be either `PSLQ` or `LLL`.|`PSLQ`
