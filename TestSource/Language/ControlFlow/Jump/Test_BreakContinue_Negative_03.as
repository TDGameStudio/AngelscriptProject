// Theme: Language.ControlFlow.Jump. Isolated compile-fail from BreakContinue_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
// sha256=8d4099a876324f3d371ade28721555bd226b3f259c89fad07cd963cd12659c82; lines 398-400.
// Oracle: compile fails — Invalid 'break' inside if but not a loop.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if (true)
	{
		break;
	}
}
