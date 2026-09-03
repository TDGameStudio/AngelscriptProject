/**
 * The other half of the import cycle: this module imports the module that
 * imports it. The preprocessor reports the chain in both directions, so this
 * file reproduces the diagnostic from the opposite end. Do not add
 * declarations that would break the cycle, since the cycle is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.CircularImportChainFromB
 * @Harness CompileReject
 * @Tag Language.Preprocessor.CircularImportChainFromB
 * @Kind CompileReject
 * @Covers Preprocessor.Imports
 * @Inputs an import of CircularA from the module CircularB
 * @Return does not preprocess; diagnostic names the circular import chain
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::CircularDependencyReportsChain block 2
 * @Provenance sha256=c3a99576f1f48a62c81f6464b1e1ee5c3f97bcfde0db6e042a73de87e8537bf6; lines 63-69.
 * @Provenance Expected diagnostic: circular chain through Tests.Preprocessor.ImportCycles.CircularA and CircularB.
 * @Provenance DiagnosticOnly. Do not add declarations that would compile this away.
 */

import Tests.Preprocessor.ImportCycles.CircularA;

/**
 * Calls into the other half of the cycle. It never runs, since the cycle is
 * detected before any code is emitted.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's FromA
 * @Return the imported value, never reached
 */
int FromB()
{
	return FromA();
}
