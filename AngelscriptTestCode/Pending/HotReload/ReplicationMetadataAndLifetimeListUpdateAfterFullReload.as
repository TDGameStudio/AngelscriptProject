/**
 * @version v1
 * @summary HotReload VersionPair Before. Replicated Score without RepNotify.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Replicated Score without RepNotify.
 * @topic Baseline
 */
// Retained across full reload: AHotReloadNetworkingReplicationActor, SetReplicates(true), Score name, CPF_Net.
// Replaced in After: Score default 1 -> 2; ReplicatedUsing=OnRep_Score; ReplicationCondition=OwnerOnly; OnRep_Score is added.
// FixtureIsolated. V1: not RepNotify, COND_None.

UCLASS()
class AHotReloadNetworkingReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	int Score = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. RepNotify Score with OwnerOnly condition.
 * @topic HotReload
 */
UCLASS()
class AHotReloadNetworkingReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(ReplicatedUsing=OnRep_Score, ReplicationCondition=OwnerOnly)
	int Score = 2;

	/** Handles the rep score callback. */
	UFUNCTION()
	void OnRep_Score()
	{
	}
}
/** @end */
