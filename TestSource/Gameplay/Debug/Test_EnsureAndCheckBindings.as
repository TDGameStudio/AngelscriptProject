// Theme: Gameplay.Debug. Value oracle: ensure/check return condition state.
// C++: AngelscriptCoverageDebugTests.cpp::EnsureAndCheckBindings ExecuteAndExpectInt 31.
// CSV NegativeDiagnostic; C++ compiles. Score bits 1+2+4+8+16=31. Passing check() allowed.
// Extra: Score starts at 0 before any ensure. DefaultSafe.

int AssertBindingSmoke()
{
	int Score = 0;

	if (ensure(true))
	{
		Score += 1;
	}
	if (!ensure(false))
	{
		Score += 2;
	}
	if (ensure(true, "CoverageEnsureMessagePass"))
	{
		Score += 4;
	}
	if (!ensure(false, "CoverageEnsureMessage"))
	{
		Score += 8;
	}
	if (!ensureAlways(false, "CoverageEnsureAlways"))
	{
		Score += 16;
	}

	check(true);
	check(true, "CoverageCheckMessagePass");

	return Score;
}

bool Observe_AssertBindingSmoke_Nominal()
{
	return AssertBindingSmoke() == 31;
}

int Observe_AssertBindingSmoke_DefaultScore()
{
	int Score = 0;
	return Score;
}
