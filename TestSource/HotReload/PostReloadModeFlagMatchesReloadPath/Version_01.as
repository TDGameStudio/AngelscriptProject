// Theme: HotReload VersionPair Version_01. GetValue returns 1.
// C++: AngelscriptHotReloadEventTests.cpp::PostReloadModeFlagMatchesReloadPath
// Retained: UPostReloadModeTarget, GetValue, live UClass object through Version_02 soft reload.
// Replaced in Version_02: Result 1 -> 2; Version_03 adds Epoch property (full reload).
// Oracle: ExecuteGetValue 1. FixtureIsolated.

UCLASS()
class UPostReloadModeTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 1;
		Log(n"HotReloadEventTests", "PostReloadMode V1 GetValue Result=" + Result);
		return Result;
	}
}
