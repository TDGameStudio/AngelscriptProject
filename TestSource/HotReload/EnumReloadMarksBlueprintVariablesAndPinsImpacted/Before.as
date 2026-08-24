// Theme: HotReload VersionPair Before. BlueprintType enum Alpha, Beta.
// C++: AngelscriptHotReloadBlueprintImpactTests.cpp::EnumReloadMarksBlueprintVariablesAndPinsImpacted
// Retained: EHotReloadBlueprintImpactState name on Blueprint StateVariable and custom-event pin.
// Replaced after After.as: enumerator set gains Gamma; enum object may be replaced.
// Oracle: PinType + VariableType impact; old enum remains on the pin until retarget.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EHotReloadBlueprintImpactState : uint8
{
	Alpha,
	Beta
}
