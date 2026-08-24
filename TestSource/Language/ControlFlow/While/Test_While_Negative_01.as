// Theme: Language.ControlFlow.While. NegativeDiagnostic: non-bool while condition.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 1
// sha256=1c7a833d70784d8b0a70d22c3fd851ec3e8bd15f2548e2f1ade9dfe968e14321; lines 244-246.
// Expected compile failure: "Non-bool while condition".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	while (5)
	{
	}
}
