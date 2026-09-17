/**
 * @version v1
 * @summary Observe script check() assertions on true conditions and capture the active AngelScript callstack as individual frames.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe script check() assertions on true conditions and capture the active AngelScript callstack as individual frames.
 * @topic Baseline
 */
// void check(bool Condition, const FString& Message);
// TArray<FString> GetAngelscriptCallstack();
// Inputs: Condition true as the known-positive path, the message
// "check passed", and the current nested call as the callstack lookup.
// Expected observations: True check() calls do not terminate. The callstack
// array is non-empty while this function is executing, frame strings are
// ordered from inner to outer, and an empty comparison against a default
// TArray shows the live stack is not empty.
// Boundary/ownership: False check() is fatal and is not invoked here. The
// returned TArray is an independent copy of frame text.

namespace TS_Debugging_Queries_01
{
	bool Observe_check_Nominal()
	{
		bool bPositive = true;
		check(bPositive);
		check(bPositive, "check passed");
		return bPositive;
	}

	bool Observe_GetAngelscriptCallstack_Nominal()
	{
		TArray<FString> Empty;
		TArray<FString> Frames = GetAngelscriptCallstack();
		int FrameCount = Frames.Num();
		if (FrameCount == 0)
		{
			return false;
		}
		return Empty.Num() == 0 && Frames[0].Len() > 0;
	}
}
/** @end */
