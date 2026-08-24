// Theme: HotReload VersionPair After. Adds Bonus=2 on the impact struct.
// C++: AngelscriptHotReloadBlueprintImpactTests.cpp::StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted
// Retained: Value=1 field and FHotReloadBlueprintImpactPayload name.
// Replaced: struct UObject identity; layout gains Bonus. Handled FullReload.
// FixtureIsolated.

USTRUCT()
struct FHotReloadBlueprintImpactPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
