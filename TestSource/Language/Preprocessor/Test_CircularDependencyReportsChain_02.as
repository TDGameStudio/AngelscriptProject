// Theme: Language.Preprocessor. Isolated compile-fail: circular import B→A.
// C++: AngelscriptPreprocessorImportTests.cpp::CircularDependencyReportsChain block 2
// sha256=c3a99576f1f48a62c81f6464b1e1ee5c3f97bcfde0db6e042a73de87e8537bf6; lines 63-69.
// Expected diagnostic: circular chain through Tests.Preprocessor.ImportCycles.CircularA and CircularB.
// DiagnosticOnly. Do not add declarations that would compile this away.

import Tests.Preprocessor.ImportCycles.CircularA;
int FromB()
{
	return FromA();
}
