// Theme: HotReload VersionPair Before. Parent NotEditable ExampleValue=15, GetValue returns 15.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::EditSpecifierReloadKeepsBlueprintChildInstanceAlive
// Retained: AHotReloadBlueprintChildEditSpecifierParent, ExampleValue storage, Blueprint child instance.
// Replaced after After.as: NotEditable -> EditAnywhere (CPF_Edit), GetValue 15 -> 16.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class AHotReloadBlueprintChildEditSpecifierParent : AActor
{
	UPROPERTY(NotEditable)
	int ExampleValue = 15;

	UFUNCTION()
	int GetValue()
	{
		return ExampleValue;
	}
}
