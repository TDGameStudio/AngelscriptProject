// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unknown GhostBuilderType.
// C++: AngelscriptCompilerBuilderIntegrationTests.cpp::RuntimeCompileFailureReportsBuilderDiagnostics
// sha256=7cbc0d3b7ac436f0e8f4506c8153a7b9565f3f124cb18467fa3a86f7d04d105b; lines 178-184.
// Expected diagnostic contains "GhostBuilderType"; compile result Error, end event failed.
// DiagnosticOnly. Do not add declarations that would compile this away.

int Entry()
{
	GhostBuilderType Value;
	return 42;
}
