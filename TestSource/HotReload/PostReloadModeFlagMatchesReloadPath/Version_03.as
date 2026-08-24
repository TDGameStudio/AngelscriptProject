// Theme: HotReload VersionPair Version_03. Structural Epoch property, GetValue returns Epoch.
// C++: AngelscriptHotReloadEventTests.cpp::PostReloadModeFlagMatchesReloadPath
// Retained: UPostReloadModeTarget, GetValue.
// Replaced: added UPROPERTY Epoch=3; GetValue returns Epoch instead of literal 1/2.
// Oracle: post-reload bWasFullReload true; Epoch property exists; ExecuteGetValue 3.
// FixtureIsolated. Full-reload path after Version_02.

UCLASS()
class UPostReloadModeTarget : UObject
{
	UPROPERTY()
	int Epoch = 3;

	UFUNCTION()
	int GetValue()
	{
		Log(n"HotReloadEventTests", "PostReloadMode V3 GetValue Epoch=" + Epoch);
		return Epoch;
	}
}
