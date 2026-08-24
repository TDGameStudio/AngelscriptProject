// Theme: HotReload VersionPair After. Live-actor lifecycle V2.
// C++: AngelscriptHotReloadLifecycleTests.cpp::DoesNotReplayBeginPlayOnLiveActor
// Retained: live actor, BeginPlayCount, PersistentCounter. V2 BeginPlay is the replaced override but must not replay on the existing instance.
// Replaced: GetValue PersistentCounter -> PersistentCounter+1; log markers V1 -> V2.
// FixtureIsolated.

UCLASS()
class AHotReloadLifecycleTarget : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int PersistentCounter = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		Log(n"HotReloadLifecycleTests", "V2 BeginPlay Count=" + BeginPlayCount + " PersistentCounter=" + PersistentCounter);
	}

	UFUNCTION()
	int GetValue()
	{
		int Result = PersistentCounter + 1;
		Log(n"HotReloadLifecycleTests", "V2 GetValue PersistentCounter=" + PersistentCounter + " Result=" + Result);
		return Result;
	}
}
