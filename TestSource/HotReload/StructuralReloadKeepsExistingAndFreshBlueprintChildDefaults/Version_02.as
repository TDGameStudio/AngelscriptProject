// Theme: HotReload VersionPair Version_02. Adds Bonus=5; GetValue = Value + Bonus.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults
// Retained: Value field (NotEditable, default 10 on existing child).
// Replaced: parent UClass (structural full reload); added Bonus; GetValue oracle 10 -> 15.
// FixtureIsolated.

UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(NotEditable)
	int Value = 10;

	UPROPERTY()
	int Bonus = 5;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value + Bonus;
	}
}
