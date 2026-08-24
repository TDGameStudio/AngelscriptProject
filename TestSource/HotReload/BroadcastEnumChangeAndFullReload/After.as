// Theme: HotReload VersionPair After. Enum gains Gamma=9, default Gamma.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastEnumChangeAndFullReload
// Retained: EHotReloadEventState, UHotReloadEventCarrier, State property, Alpha, Beta=4.
// Replaced: Gamma=9; default State = EHotReloadEventState::Gamma.
// Oracle: FullReloadCount 1, EnumChangedCount 1. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadEventState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UHotReloadEventCarrier : UObject
{
	UPROPERTY()
	EHotReloadEventState State;

	default State = EHotReloadEventState::Gamma;
}
