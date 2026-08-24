// Theme: HotReload VersionPair Version_03. EditAnywhere Value=20, Bonus=7.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults
// Retained on existing Blueprint child: prior Value=10 and Bonus=5 (GetValue 15).
// Replaced: parent UClass again; Value CPF_Edit; script defaults 20/7.
// Oracle: existing child GetValue==15; fresh parent/Blueprint GetValue==27.
// FixtureIsolated.

UCLASS()
class AHotReloadBlueprintChildStructuralParent : AActor
{
	UPROPERTY(EditAnywhere)
	int Value = 20;

	UPROPERTY()
	int Bonus = 7;

	UFUNCTION()
	int GetValue()
	{
		return Value + Bonus;
	}
}
