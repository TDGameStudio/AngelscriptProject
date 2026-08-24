// Theme: HotReload VersionPair After. Adds Gamma enumerator.
// C++: AngelscriptHotReloadBlueprintImpactTests.cpp::EnumReloadMarksBlueprintVariablesAndPinsImpacted
// Retained: Alpha, Beta names; Blueprint variable still points at the old enum until retarget.
// Replaced: enumerator set (Gamma). Handled FullReload; PinType + VariableType impact.
// FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadBlueprintImpactState : uint8
{
	Alpha,
	Beta,
	Gamma
}
