// Theme: HotReload VersionPair After. RepNotify Score with OwnerOnly condition.
// C++: AngelscriptHotReloadNetworkingTests.cpp::ReplicationMetadataAndLifetimeListUpdateAfterFullReload
// Retained: actor name, SetReplicates(true), Score remains CPF_Net.
// Replaced: Score=2, ReplicatedUsing=OnRep_Score, ReplicationCondition=OwnerOnly, OnRep_Score exists. Full reload replaces UClass.
// FixtureIsolated.

UCLASS()
class AHotReloadNetworkingReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(ReplicatedUsing=OnRep_Score, ReplicationCondition=OwnerOnly)
	int Score = 2;

	UFUNCTION()
	void OnRep_Score()
	{
	}
}
