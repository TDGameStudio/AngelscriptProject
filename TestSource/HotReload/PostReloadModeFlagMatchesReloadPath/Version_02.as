// Theme: HotReload VersionPair Version_02. Soft body GetValue 2.
// C++: AngelscriptHotReloadEventTests.cpp::PostReloadModeFlagMatchesReloadPath
// Retained: UPostReloadModeTarget class object identity, GetValue name, no new properties.
// Replaced: Result 1 -> 2. Oracle: post-reload bWasFullReload false; ExecuteGetValue 2.
// FixtureIsolated. Pair with Version_01.

UCLASS()
class UPostReloadModeTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 2;
		Log(n"HotReloadEventTests", "PostReloadMode V2 GetValue Result=" + Result);
		return Result;
	}
}
