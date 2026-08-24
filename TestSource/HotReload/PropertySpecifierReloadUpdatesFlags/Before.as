// Theme: HotReload VersionPair Before. Specifier NotEditable -> EditAnywhere.
// C++: AngelscriptHotReloadPropertyTests.cpp::PropertySpecifierReloadUpdatesFlags ScriptV1
// Retained on old class: Value storage; CPF_Edit unset (NotEditable).
// Replaced in After: UPROPERTY EditAnywhere; Value default 1 -> 2.
// Oracle Before: CPF_Edit false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadSpecifierTarget : UObject
{
	UPROPERTY(NotEditable)
	int Value;

	default Value = 1;
}
