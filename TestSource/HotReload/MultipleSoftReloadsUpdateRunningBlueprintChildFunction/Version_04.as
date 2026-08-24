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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	int ComputeBonus()
	{
		return 30;
	}

	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
