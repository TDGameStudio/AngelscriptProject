// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: duplicate case labels.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 1
// sha256=fa7285699d24d33792cf32e8bc90d45ea274813098584f7bac4da7e21aa1443f; lines 323-325.
// Expected compile failure: "Duplicate case labels".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	switch (X)
	{
		case 1:
			break;
		case 1:
			break;
	}
}
