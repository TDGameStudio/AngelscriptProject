// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: non-constant case expression.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 2
// sha256=80d3ff24c3ba026a897f13ef210a9a6cab9194401099b647a341cbacc8f84fb7; lines 330-332.
// Expected compile failure: "Non-constant case expression".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	int Y = 2;
	switch (X)
	{
		case Y:
			break;
	}
}
