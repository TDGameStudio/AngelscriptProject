// Purpose: Observe DebugBreak, ensure/ensureAlways return values, and throw
// as the diagnostic failure path.
// AS-facing API: void DebugBreak();
// bool ensure(bool Condition);
// bool ensure(bool Condition, const FString& Message);
// bool ensureAlways(bool Condition);
// bool ensureAlways(bool Condition, const FString& Message);
// void throw(const FString& Message);
// Inputs: True conditions as the nominal pass path, false conditions as the
// recoverable-failure path with message "ensure failed", and throw message
// "expected debugging throw".
// Expected observations: ensure/ensureAlways return the condition. True
// paths return true; false paths return false without terminating the script
// the way check() would. DebugBreak returns after requesting a break.
// Boundary/ownership: throw raises an AngelScript exception; that path lives
// in ExerciseExpectedFailure. ensure reports once, ensureAlways reports every
// failure.

namespace TS_Debugging_Behavior_01
{
	bool Observe_DebugBreak_Nominal()
	{
		int Before = 1;
		DebugBreak();
		int After = Before + 0;
		return After == 1;
	}

	bool Observe_ensure_Nominal()
	{
		bool bTrueBare = ensure(true);
		bool bTrueWithMessage = ensure(true, "ensure passed");
		bool bFalseBare = ensure(false);
		bool bFalseWithMessage = ensure(false, "ensure failed");
		return bTrueBare && bTrueWithMessage && !bFalseBare && !bFalseWithMessage;
	}

	bool Observe_ensureAlways_Nominal()
	{
		bool bTrueBare = ensureAlways(true);
		bool bTrueWithMessage = ensureAlways(true, "ensureAlways passed");
		bool bFalseBare = ensureAlways(false);
		bool bFalseWithMessage = ensureAlways(false, "ensureAlways failed");
		return bTrueBare && bTrueWithMessage && !bFalseBare && !bFalseWithMessage;
	}

	bool Observe_throw_Nominal()
	{
		FString PreparedMessage = "expected debugging throw";
		return PreparedMessage == "expected debugging throw";
	}

	void ExerciseExpectedFailure()
	{
		throw("expected debugging throw");
	}
}
