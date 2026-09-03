// Theme: HotReload VersionPair After. Enum gains Gamma=9; probe Gamma -> 9.
// C++: AngelscriptHotReloadEnumDelegateTests.cpp::BroadcastEnumChangedOnFullReload
// Retained: EHotReloadChangedState, UHotReloadEnumChangedCarrier, State, Alpha, Beta=4, RunChangedEnumProbe.
// Replaced: Gamma=9; default State = Gamma; probe uses Gamma.
// Oracle: FullReloadCount 1, EnumChangedCount 1, RunChangedEnumProbe -> 9. FixtureIsolated.

UENUM(BlueprintType)
enum class EHotReloadChangedState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UHotReloadEnumChangedCarrier : UObject
{
	UPROPERTY()
	EHotReloadChangedState State;

	default State = EHotReloadChangedState::Gamma;
}

/** Runs the changed enum probe path and returns the observed result. */
int RunChangedEnumProbe()
{
	EHotReloadChangedState State = EHotReloadChangedState::Gamma;
	int Result = State == EHotReloadChangedState::Gamma ? 9 : 0;
	Log(n"HotReloadEnumDelegateTests", "Changed V2 RunChangedEnumProbe State=Gamma Result=" + Result);
	return Result;
}
