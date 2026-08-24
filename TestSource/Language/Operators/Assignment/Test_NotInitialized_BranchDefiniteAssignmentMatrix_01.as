// Theme: Language.Operators.Assignment. Positive compile with uninitialized warning.
// C++: AngelscriptControlFlowTests.cpp::NotInitialized_BranchDefiniteAssignmentMatrix
// sha256=c0e891844fdb67e46cafc1c01bc22fc40ab3345075021683b1b1b0f9c083d365; lines 288-298.
// C++ still compiles (bCompileSucceeded=true) and expects a "may not be initialized" warning for Value.
// Oracle: RunPartial(true) assigns 7. False branch is the warning path, not a value oracle.
// Extra: true branch is the assigned vector; default Value is uninitialized.
// DefaultSafe. Source owns locals.

int RunPartial(bool bFlag)
{
	int Value;
	if (bFlag)
	{
		Value = 7;
	}
	return Value;
}

bool Observe_RunPartial_TrueBranch()
{
	return RunPartial(true) == 7;
}
