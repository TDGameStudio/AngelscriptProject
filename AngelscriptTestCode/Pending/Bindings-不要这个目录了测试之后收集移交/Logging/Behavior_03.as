/**
 * @version v1
 * @summary Observe Throw and ThrowIf, keeping the actual exception on the void ThrowIf(bool Condition, const FString& Text); empty text as a boundary message, and Condition true only inside ExerciseExpectedFailure.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Throw and ThrowIf, keeping the actual exception on the void ThrowIf(bool Condition, const FString& Text); empty text as a boundary message, and Condition true only inside ExerciseExpectedFailure.
 * @topic Baseline
 */
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
/** @end */
