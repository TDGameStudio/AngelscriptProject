// Theme: HotReload VersionPair After. Specifier NotEditable -> EditAnywhere.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertySpecifierReloadUpdatesFlags ScriptV2
// Retained: UFullReloadSpecifierTarget name; Value property.
// Replaced: EditAnywhere (CPF_Edit); default Value 2.
// Oracle After: FullReload handled; replacement flags include CPF_Edit.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadSpecifierTarget : UObject
{
	UPROPERTY(EditAnywhere)
	int Value;

	default Value = 2;
}
