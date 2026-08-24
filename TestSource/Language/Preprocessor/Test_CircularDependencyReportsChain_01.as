// Theme: Language.Preprocessor. Isolated compile-fail: circular import A→B.
// C++: AngelscriptPreprocessorImportTests.cpp::CircularDependencyReportsChain block 1
// sha256=b33775f74ea5b0eb6e6e0275d32788ac8716b7b68d94f0cee352757e8ff6a000; lines 55-61.
// Expected diagnostic: "Detected circular import of module Tests.Preprocessor.ImportCycles.CircularA. Import chain:"
// plus "=> Tests.Preprocessor.ImportCycles.CircularB" and "=> Tests.Preprocessor.ImportCycles.CircularA" (count >= 3).
// DiagnosticOnly. Do not add declarations that would compile this away.

import Tests.Preprocessor.ImportCycles.CircularB;
int FromA()
{
	return FromB();
}
