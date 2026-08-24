// Theme: HotReload VersionPair Before. Enum enumerator set and default State.
// C++: AngelscriptHotReloadPropertyTests.cpp::FullReloadUpdatesEnumValueAndDefault ScriptV1
// Retained: EFullReloadEnumState; Alpha; Beta=4; UFullReloadEnumTarget.State field.
// Replaced in After: Gamma=9 enumerator; default State Alpha -> Gamma.
// Oracle Before: enum metadata present; State defaults to Alpha.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EFullReloadEnumState : uint16
{
	Alpha,
	Beta = 4
}

UCLASS()
class UFullReloadEnumTarget : UObject
{
	UPROPERTY()
	EFullReloadEnumState State;

	default State = EFullReloadEnumState::Alpha;
}
