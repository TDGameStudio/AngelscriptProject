/**
 * ensure, ensureAlways and check, each observed through the condition state they
 * return. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and
 * executes AssertBindingSmoke expecting 31, so this is a value oracle. The score is a
 * bitmask, one bit per ensure form that returned the expected state. Passing checks are
 * allowed and contribute nothing to the score.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.EnsureAndCheckBindings
 * @Harness Function
 * @Tag Gameplay.Debug.EnsureAndCheckBindings
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Value oracle: ensure/check return condition state.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::EnsureAndCheckBindings ExecuteAndExpectInt 31.
 * @Provenance CSV NegativeDiagnostic; C++ compiles. Score bits 1+2+4+8+16=31. Passing check() allowed.
 * @Provenance Extra: Score starts at 0 before any ensure. DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * The entrypoint C++ executes, collecting one bit per ensure form that returned the
	 * expected condition state.
	 *
	 * @Kind Observe
	 * @Covers Debug.EnsureAndCheckBindings
	 * @Inputs none
	 * @Return 31 when all five forms scored
	 */
	UFUNCTION()
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

	/**
	 * Observe that every ensure form scored.
	 *
	 * @Kind Observe
	 * @Covers Debug.EnsureAndCheckBindings
	 * @Inputs none
	 * @Return true when the score is 31
	 */
	UFUNCTION()
	bool AssertBindingSmokeNominal()
	{
		return AssertBindingSmoke() == 31;
	}

	/**
	 * Observe the baseline score before any ensure has run.
	 *
	 * @Kind Observe
	 * @Covers Debug.EnsureAndCheckBindings
	 * @Inputs none
	 * @Return 0, the score before any work is done
	 * @Boundary before any ensure
	 */
	UFUNCTION()
	int DefaultScore()
	{
		int Score = 0;
		return Score;
	}
}
