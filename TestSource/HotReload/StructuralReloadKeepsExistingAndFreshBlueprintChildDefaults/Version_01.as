// Theme: HotReload VersionPair Version_01. Structural parent NotEditable Value=10, GetValue=10.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults
// Retained later: existing Blueprint child Value default 10 once Bonus is added.
// Replaced later: add Bonus; then EditAnywhere Value=20 Bonus=7 (parent UClass replaced each full reload).
// Oracle: GetValue==10 before first structural reload; CPF_Edit clear on Value.
// FixtureIsolated. Load Version_01..03 in recorded order.

UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(NotEditable)
	int Value = 10;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
