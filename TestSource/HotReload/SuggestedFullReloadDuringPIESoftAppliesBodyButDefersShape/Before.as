// Theme: HotReload VersionPair Before. During-PIE suggested-full enum+body V1.
// C++: AngelscriptHotReloadPIESessionTests.cpp::SuggestedFullReloadDuringPIESoftAppliesBodyButDefersShape
// Retained during PIE: enum class EHotReloadPIESuggestedState Alpha=1 Beta=4, State default Alpha, GetValue arity.
// Replaced in After: Beta 4 -> 7 (deferred shape); GetValue 33 -> 44 (soft body may apply). PlannedSymbols include `class` from enum class / UCLASS.
// FixtureIsolated. C++ baseline GetValue is 33.

UENUM(BlueprintType)
enum class EHotReloadPIESuggestedState : uint16
{
	Alpha = 1,
	Beta = 4
}

UCLASS(Blueprintable)
class AHotReloadPIEDuringSuggestedGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadPIEDuringSuggestedLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	EHotReloadPIESuggestedState State;

	default State = EHotReloadPIESuggestedState::Alpha;

	UFUNCTION()
	int GetValue()
	{
		return 33;
	}
}
