// Theme: HotReload VersionPair Version_03. Provider struct gains Bonus=2.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderStructFullReloadRetargetsConsumerFunctionParameter
// Retained: FHotReloadDependencyPayload, Value=1.
// Replaced: Bonus=2; struct UScriptStruct object identity.
// Oracle: full reload replaces struct object; Bonus property exists. FixtureIsolated. Provider file.

USTRUCT()
struct FHotReloadDependencyPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
