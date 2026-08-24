// Theme: Language.ControlFlow.Foreach. Isolated compile-fail from Foreach_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Negative
// sha256=50bd28cfe810fa9f66c788c21e4e1d62c9bd697e7e1818c090dcacfdb87bc3f1; lines 492-494.
// Oracle: compile fails — foreach element type mismatch (FString over TArray<int>).
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	TArray<int> Arr;
	for (FString Val : Arr)
	{
	}
}
