// Theme: HotReload VersionPair Version_02. ComputeBonus helper body returns 1.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::MultipleSoftReloadsUpdateRunningBlueprintChildFunction
// Retained: parent UClass, Blueprint child, BeginPlayCount==1 (BeginPlay not replayed).
// Replaced: ComputeBonus 0 -> 1; GetValue oracle 10 -> 11.
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
		return 1;
	}

	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
