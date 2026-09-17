/**
 * @version v1
 * @summary Observe Unreal process-mode globals for commandlet detection.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Unreal process-mode globals for commandlet detection.
 * @topic Baseline
 */
// bool IsRunningDLCCookCommandlet(); UClass GetRunningCommandletClass();
// Inputs: Runner-supplied expected commandlet flags for the current process.
// Editor automation is the expected negative commandlet state.
// Expected observations: Each bool query matches bExpect*. GetRunningCommandletClass
// is null when not running a commandlet and non-null when running one.
// Boundary/ownership: These globals report process state and do not allocate
// or own a commandlet instance. The returned UClass is borrowed.

namespace TS_CoreGlobals_Queries_01
{
	bool Observe_IsRunningCommandlet_Nominal(bool bExpectCommandlet)
	{
		return IsRunningCommandlet() == bExpectCommandlet;
	}

	bool Observe_IsRunningCookCommandlet_Nominal(bool bExpectCookCommandlet)
	{
		bool bCooking = IsRunningCookCommandlet();
		bool bImpliesCommandlet = !bCooking || IsRunningCommandlet();
		return bCooking == bExpectCookCommandlet && bImpliesCommandlet;
	}

	bool Observe_IsRunningDLCCookCommandlet_Nominal(bool bExpectDlcCookCommandlet)
	{
		bool bDlcCook = IsRunningDLCCookCommandlet();
		bool bImpliesCook = !bDlcCook || IsRunningCookCommandlet();
		return bDlcCook == bExpectDlcCookCommandlet && bImpliesCook;
	}

	bool Observe_GetRunningCommandletClass_Nominal(bool bExpectCommandlet)
	{
		UClass CommandletClass = GetRunningCommandletClass();
		if (bExpectCommandlet)
		{
			return IsRunningCommandlet() && CommandletClass != nullptr;
		}
		return !IsRunningCommandlet() && CommandletClass is null;
	}
}
/** @end */
