// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: float as case value.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 6
// sha256=d0f53cafc02dcac68ee0790a3e106a205f06678c24a2f9ad38c4d3343b34e06a; lines 358-360.
// Expected compile failure: "Float as case value".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	switch (X)
	{
		case 1.5f:
			break;
	}
}
