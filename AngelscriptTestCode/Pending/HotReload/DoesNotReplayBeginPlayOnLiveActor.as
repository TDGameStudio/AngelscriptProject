/**
 * @version v1
 * @summary HotReload VersionPair Before. Live-actor lifecycle V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Live-actor lifecycle V1.
 * @topic Baseline
 */
// Retained after soft reload: BeginPlayCount / PersistentCounter instance values; BeginPlay must not re-run on the live actor.
// Replaced in After: GetValue returns PersistentCounter+1 and V2 log text; BeginPlay log prefix V1 -> V2.
// FixtureIsolated. C++ oracle: BeginPlayCount stays 1, GetValue V1 is PersistentCounter.

UCLASS()
class AHotReloadLifecycleTarget : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int PersistentCounter = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		Log(n"HotReloadLifecycleTests", "V1 BeginPlay Count=" + BeginPlayCount + " PersistentCounter=" + PersistentCounter);
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		Log(n"HotReloadLifecycleTests", "V1 GetValue PersistentCounter=" + PersistentCounter);
		return PersistentCounter;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Live-actor lifecycle V2.
 * @topic HotReload
 */
UCLASS()
class AHotReloadLifecycleTarget : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int PersistentCounter = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
		Log(n"HotReloadLifecycleTests", "V2 BeginPlay Count=" + BeginPlayCount + " PersistentCounter=" + PersistentCounter);
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		int Result = PersistentCounter + 1;
		Log(n"HotReloadLifecycleTests", "V2 GetValue PersistentCounter=" + PersistentCounter + " Result=" + Result);
		return Result;
	}
}
/** @end */
