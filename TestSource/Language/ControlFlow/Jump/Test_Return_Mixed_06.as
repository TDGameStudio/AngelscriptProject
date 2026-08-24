// Theme: Language.ControlFlow.Jump. Isolated compile-fail from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=071ceef72f52ccb6c34ae680d0027dea246bb3c92700fbf1b51a860a9b57b110; lines 567-569.
// Oracle: compile fails — missing return value in a non-void function.
// CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
// DiagnosticOnly. Source owns the isolated failing program.

int Test()
{
	return;
}
