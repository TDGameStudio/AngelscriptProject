// Theme: HotReload VersionPair Version_04. ComputeBonus helper body returns 30.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::MultipleSoftReloadsUpdateRunningBlueprintChildFunction
// Retained: live Blueprint child, BeginPlayCount==1, Value=10, same UClass.
// Replaced: ComputeBonus 31-path -> 30; GetValue oracle 31 -> 40.
// FixtureIsolated.

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
		return 30;
	}

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
