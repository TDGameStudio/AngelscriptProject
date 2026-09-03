// Theme: HotReload VersionPair Before. Last-good GetValue 5.
// C++: AngelscriptHotReloadEventTests.cpp::FailedReloadDoesNotBroadcastReloadDelegates
// Retained after failed After: UFailedReloadEventTarget, GetValue 5, generated class identity.
// Replaced in After: MissingType GetValue (does not compile).
// Oracle: ExecuteGetValue 5 before and after failed reload. FixtureIsolated.

UCLASS()
class UFailedReloadEventTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = 5;
		Log(n"HotReloadEventTests", "FailedReload V1 GetValue Result=" + Result);
		return Result;
	}
}
