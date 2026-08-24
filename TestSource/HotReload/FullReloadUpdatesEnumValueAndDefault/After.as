// Theme: HotReload VersionPair After. Enum enumerator set and default State.
// C++: AngelscriptHotReloadPropertyTests.cpp::FullReloadUpdatesEnumValueAndDefault ScriptV2
// Retained: EFullReloadEnumState; Alpha; Beta=4; State property.
// Replaced: Gamma=9; default State Gamma; reloaded instance reads 9.
// Oracle After: FullReload handled; enum UObject still present; State default 9.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EFullReloadEnumState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UFullReloadEnumTarget : UObject
{
	UPROPERTY()
	EFullReloadEnumState State;

	default State = EFullReloadEnumState::Gamma;
}
