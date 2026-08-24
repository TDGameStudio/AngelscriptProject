// Theme: Language.ControlFlow.Jump. Isolated compile-fail from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=20fd88fe6b5168541e126a00e0794b9021e58b2167d4ff78b35edbfb8763c71a; lines 553-555.
// Oracle: compile fails — return type mismatch (string for int).
// CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
// DiagnosticOnly. Source owns the isolated failing program.

int Test()
{
	return "hello";
}
