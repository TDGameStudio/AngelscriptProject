// Theme: Language.Operators.Assignment. Positive definite-assignment both branches.
// C++: AngelscriptControlFlowTests.cpp::NotInitialized_BranchDefiniteAssignmentMatrix
// sha256=184fb7a869e7a0e65d8ced13c736700d32e26ea666d93242d502d711c8089438; lines 323-347.
// Oracle: RunSafeTrue 7; RunSafeFalse 9. No uninitialized warning for Value.
// Extra: both bool wrappers; Compute is the shared assignment matrix.
// DefaultSafe. Source owns locals.

int Compute(bool bFlag)
{
	int Value;
	if (bFlag)
	{
		Value = 7;
	}
	else
	{
		Value = 9;
	}
	return Value;
}

int RunSafeTrue()
{
	return Compute(true);
}

int RunSafeFalse()
{
	return Compute(false);
}

bool Observe_DefiniteAssignment_Nominal()
{
	return RunSafeTrue() == 7 && RunSafeFalse() == 9;
}

bool Observe_DefiniteAssignment_DirectCompute()
{
	return Compute(true) == 7 && Compute(false) == 9;
}
