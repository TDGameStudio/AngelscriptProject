// Theme: HotReload VersionPair After. Same class; EditAnywhere and GetValue + 1.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::EditSpecifierReloadKeepsBlueprintChildInstanceAlive
// Retained: ExampleValue storage (15) and Blueprint child instance identity.
// Replaced: edit specifier NotEditable -> EditAnywhere (CPF_Edit); GetValue 15 -> 16.
// Oracle: handled FullReload; ExampleValue still present; child pointer remains usable.
// FixtureIsolated.

UCLASS()
class AHotReloadBlueprintChildEditSpecifierParent : AActor
{
	UPROPERTY(EditAnywhere)
	int ExampleValue = 15;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue + 1;
	}
}
