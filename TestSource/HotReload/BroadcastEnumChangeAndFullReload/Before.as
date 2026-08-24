// Theme: HotReload VersionPair Before. Enum Alpha/Beta=4, default Alpha.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastEnumChangeAndFullReload
// Retained after reload: EHotReloadEventState, UHotReloadEventCarrier, State property, Alpha/Beta=4.
// Replaced in After: Gamma=9 added; default State = Gamma.
// Oracle: FullReload + OnEnumChanged once; old names count 2. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadEventState : uint16
{
	Alpha,
	Beta = 4
}

UCLASS()
class UHotReloadEventCarrier : UObject
{
	UPROPERTY()
	EHotReloadEventState State;

	default State = EHotReloadEventState::Alpha;
}
