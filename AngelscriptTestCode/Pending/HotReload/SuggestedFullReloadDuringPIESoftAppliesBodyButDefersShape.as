/**
 * @version v1
 * @summary HotReload VersionPair Before. During-PIE suggested-full enum+body V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. During-PIE suggested-full enum+body V1.
 * @topic Baseline
 */
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

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 33;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. During-PIE suggested-full enum+body V2.
 * @topic HotReload
 */
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

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 44;
	}
}
/** @end */
