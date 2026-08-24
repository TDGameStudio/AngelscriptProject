// Theme: Language.ControlFlow.While. NegativeDiagnostic: integer as do-while condition.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 6
// sha256=361f5dc0961dce8b44c14a7b8e4b9c15eaa08651a7ff64b596fc738859e80c6e; lines 279-281.
// Expected compile failure: "Integer as do-while condition".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	do
	{
	} while (1);
}
