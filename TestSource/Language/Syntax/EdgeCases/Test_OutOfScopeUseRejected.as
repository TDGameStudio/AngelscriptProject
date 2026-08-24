// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: out-of-scope local.
// C++: AngelscriptCompilerModulePipelineTests.cpp::OutOfScopeUseRejected
// sha256=24537273dea1397e995a642000fcbb27180bceeadb28e8dc8fa0b2b08323ee50; lines 174-182.
// Expected diagnostic: missing variable Inner after the inner block ends.
// Isolate this failing program; do not add declarations that would compile it
// away. DiagnosticOnly.

int Entry()
{
	{
		int Inner = 2;
	}
	return Inner;
}
