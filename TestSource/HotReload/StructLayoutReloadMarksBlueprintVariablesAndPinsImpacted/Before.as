// Theme: HotReload VersionPair Before. Impact struct payload Value=1 only.
// C++: AngelscriptHotReloadBlueprintImpactTests.cpp::StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted
// Retained: FHotReloadBlueprintImpactPayload name used by Blueprint variables and custom-event pins.
// Replaced after After.as: struct object identity (layout full reload) plus Bonus=2.
// Oracle: PinType + VariableType impact; Blueprint variable retargets to new UScriptStruct.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadBlueprintImpactPayload
{
	UPROPERTY()
	int Value = 1;
}
