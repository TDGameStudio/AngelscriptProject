// Theme: HotReload VersionPair After. During-PIE suggested-full enum+body V2.
// C++: AngelscriptHotReloadPIESessionTests.cpp::SuggestedFullReloadDuringPIESoftAppliesBodyButDefersShape
// Retained during PIE: State property and enum class type identity; Beta enumerator value change is deferred shape.
// Replaced: GetValue 33 -> 44 may apply as a soft body; Beta 4 -> 7 waits for the deferred full path.
// FixtureIsolated. PartiallyHandled. PlannedSymbols include `class`.

UENUM(BlueprintType)
enum class EHotReloadPIESuggestedState : uint16
{
	Alpha = 1,
	Beta = 7
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
		return 44;
	}
}
