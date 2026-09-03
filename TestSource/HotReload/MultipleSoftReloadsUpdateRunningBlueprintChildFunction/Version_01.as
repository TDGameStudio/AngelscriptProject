// Theme: HotReload VersionPair Version_01. Soft sequence baseline ComputeBonus=0, GetValue=10.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::MultipleSoftReloadsUpdateRunningBlueprintChildFunction
// Retained across later versions: class identity, Value=10, BeginPlayCount not replayed (stays 1).
// Replaced later: ComputeBonus body 0 -> 1 -> BeginPlayCount+20 -> 30 (GetValue 10, 11, 31, 40).
// Oracle: GetValue==10; BeginPlayCount==1 after first BeginPlay.
// FixtureIsolated. Load Version_01..04 in recorded order.

UCLASS()
class AHotReloadBlueprintChildSoftSequenceParent : AActor
{
	UPROPERTY()
	int Value = 10;

	UPROPERTY()
	int BeginPlayCount = 0;

	/** Blueprint begin-play override: binds the delegate and records the entry. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/** Computes the bonus and returns the result. */
	int ComputeBonus()
	{
		return 0;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
