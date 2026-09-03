/**
 * A module that imports another module which imports back forms an import
 * cycle, which the preprocessor reports with the full chain. This file is one
 * half of the cycle; the diagnostic names both modules. Do not add
 * declarations that would break the cycle, since the cycle is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.CircularImportChainFromA
 * @Harness CompileReject
 * @Tag Language.Preprocessor.CircularImportChainFromA
 * @Kind CompileReject
 * @Covers Preprocessor.Imports
 * @Inputs an import of CircularB from the module CircularA
 * @Return does not preprocess; diagnostic names the circular import chain
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::CircularDependencyReportsChain block 1
 * @Provenance sha256=b33775f74ea5b0eb6e6e0275d32788ac8716b7b68d94f0cee352757e8ff6a000; lines 55-61.
 * @Provenance Expected diagnostic: "Detected circular import of module Tests.Preprocessor.ImportCycles.CircularA. Import chain:"
 * @Provenance plus "=> Tests.Preprocessor.ImportCycles.CircularB" and "=> Tests.Preprocessor.ImportCycles.CircularA" (count >= 3).
 * @Provenance DiagnosticOnly. Do not add declarations that would compile this away.
 */

import Tests.Preprocessor.ImportCycles.CircularB;

/**
 * Calls into the other half of the cycle. It never runs, since the cycle is
 * detected before any code is emitted.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported module's FromB
 * @Return the imported value, never reached
 */
int FromA()
{
	return FromB();
}
