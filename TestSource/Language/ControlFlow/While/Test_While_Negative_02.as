// Theme: Language.ControlFlow.While. NegativeDiagnostic: while without parentheses.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 2
// sha256=53f8c3d1f0f71233288f73dbb745a655e7e4a67c833566335b974d98a72e0dbc; lines 251-253.
// Expected compile failure: "While without parentheses".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	while true
	{
	}
}
