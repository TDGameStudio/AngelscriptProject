// Theme: Language.ControlFlow.While. NegativeDiagnostic: integer as while condition.
// C++: AngelscriptSyntaxControlFlowTests.cpp::While_Negative block 5
// sha256=6d48759bbb82ca73fc30a839a20d0dd41762caae810a18041d3ab8589eb28edd; lines 272-274.
// Expected compile failure: "Integer as while condition".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	while (X)
	{
		break;
	}
}
