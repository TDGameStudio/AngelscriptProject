// Theme: Language.ControlFlow.While. NegativeDiagnostic: do-while missing semicolon.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 4
// sha256=31297f6b30a2955e005bece58e6828f950089fabe4c6629f0bc3635b945cfc3a; lines 265-267.
// Expected compile failure: "Do-while missing semicolon".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	do
	{
	} while (true)
}
