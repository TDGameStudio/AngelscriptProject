// Theme: HotReload VersionPair Version_03. ComputeBonus reads live BeginPlayCount + 20.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::MultipleSoftReloadsUpdateRunningBlueprintChildFunction
// Retained: live actor, BeginPlayCount==1, Value=10, same UClass.
// Replaced: ComputeBonus body; GetValue oracle 11 -> 31.
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
		return BeginPlayCount + 20;
	}

	UFUNCTION()
	int GetValue()
	{
		return Value + ComputeBonus();
	}
}
