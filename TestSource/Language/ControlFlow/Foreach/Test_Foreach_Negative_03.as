// Theme: Language.ControlFlow.Foreach. Isolated compile-fail from Foreach_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Negative
// sha256=a841a93132ccdb4a2bf6b93325e2c1e752d78f649e62fade38596d5b464743f7; lines 499-501.
// Oracle: compile fails — foreach missing colon.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	TArray<int> Arr;
	for (int Val Arr)
	{
	}
}
