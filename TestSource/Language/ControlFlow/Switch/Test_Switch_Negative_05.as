// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: switch without braces.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 5
// sha256=2753ad1d94c291382c6f730a98259e9aa5bc9b927054422014395e18de29bae3; lines 351-353.
// Expected compile failure: "Switch without braces".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	switch (X) case 0: break;
}
