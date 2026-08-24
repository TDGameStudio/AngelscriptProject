// Purpose: Observe Throw and ThrowIf, keeping the actual exception on the
// expected-failure path. ThrowIf(false) returns without raising.
// AS-facing API: void Throw(const FString& Text);
// void ThrowIf(bool Condition, const FString& Text);
// Inputs: Text "expected logging throw", Condition false as the no-op path,
// empty text as a boundary message, and Condition true only inside
// ExerciseExpectedFailure.
// Expected observations: ThrowIf(false) returns without raising. Prepared
// messages remain independent FString values.
// Boundary/ownership: Throw raises an AngelScript exception with Text. The
// script does not continue after a successful Throw.

namespace TS_Logging_Behavior_03
{
	bool Observe_Throw_Nominal()
	{
		FString Prepared = "expected logging throw";
		return Prepared == "expected logging throw" && Prepared.Len() > 0;
	}

	bool Observe_ThrowIf_Nominal()
	{
		FString Suppressed = "suppressed throw";
		ThrowIf(false, Suppressed);
		ThrowIf(false, "");
		return Suppressed == "suppressed throw";
	}

	void ExerciseExpectedFailure()
	{
		Throw("expected logging throw");
	}
}
