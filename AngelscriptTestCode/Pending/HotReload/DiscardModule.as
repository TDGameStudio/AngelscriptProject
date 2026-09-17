/**
 * @version v1
 * @summary HotReload VersionPair Before. Discardable module.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Discardable module.
 * @topic Baseline
 */
// Retained until discard: UDiscardableObject / GetScore / Score default 42 and the module record.
// Replaced after DiscardModule: this class and record are gone. After.as is the survivor, not a rewrite of this type.
// FixtureIsolated. Oracle GetScore is not executed; discard removes the module.

UCLASS()
class UDiscardableObject : UObject
{
	UPROPERTY()
	int Score;

	default Score = 42;

	/** Returns the score. */
	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Survivor module.
 * @topic HotReload
 */
/** SurvivorEntry: exercises the survivor entry behaviour. */
int SurvivorEntry()
{
	return 99;
}
/** @end */
