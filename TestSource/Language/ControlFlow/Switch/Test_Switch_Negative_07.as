// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: string case on int switch.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 7
// sha256=241c822b31337247b95c8c812f56e39398a49a912918f80641106a7f65f773de; lines 365-367.
// Expected compile failure: "String as case value for int switch".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	switch (X)
	{
		case "hello":
			break;
	}
}
