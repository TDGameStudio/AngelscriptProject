// Theme: Language.ControlFlow.While. NegativeDiagnostic: while with empty condition.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 3
// sha256=7301517ccd20f8e43ff655d66dfa9490135e78b1f6595ea4015e585088ef547d; lines 258-260.
// Expected compile failure: "While with empty condition".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	while ()
	{
	}
}
