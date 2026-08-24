// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: multiple default labels.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 3
// sha256=0cea3c7f5a270d9c0b4e603fa1350869b6a59ef994d611d3eeb6f59b8dfae63f; lines 337-339.
// Expected compile failure: "Multiple default labels".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	switch (X)
	{
		default:
			break;
		default:
			break;
	}
}
