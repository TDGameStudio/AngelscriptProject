// Theme: HotReload VersionPair Before. Replicated Score without RepNotify.
// C++: AngelscriptHotReloadNetworkingTests.cpp::ReplicationMetadataAndLifetimeListUpdateAfterFullReload
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
