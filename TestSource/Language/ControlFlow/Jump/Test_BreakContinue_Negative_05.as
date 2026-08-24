// Theme: Language.ControlFlow.Jump. Isolated compile-fail from BreakContinue_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
// sha256=6cdb47cd2e19aaed71c3b7a12fc1043c7ae24af6c3c5a1f172063b5dcfbd412e; lines 414-421.
// Oracle: compile fails — Invalid 'break' inside a function called from a loop (break does not propagate).
// DiagnosticOnly. Source owns the isolated failing program.

void Foo()
{
	break;
}

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		Foo();
	}
}
