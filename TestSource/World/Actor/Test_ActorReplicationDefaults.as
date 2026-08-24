// Theme: World.Actor. WorldStory: default SetReplicates/SetReplicateMovement
// apply at instance construction; Health is CPF_Net.
// C++: AngelscriptCoverageNetworkingTests.cpp::ActorReplicationDefaults
// Oracle: spawned instance GetIsReplicated true, IsReplicatingMovement true, Health=100.
// Extra: unreplicated sibling Health 0 is the false/empty boundary. FixtureIsolated.

UCLASS()
class ACoverageNetworkingConfigActor : AActor
{
	default SetReplicates(true);
	default SetReplicateMovement(true);

	UPROPERTY(Replicated)
	int Health = 100;
}

UCLASS()
class ACoverageNetworkingConfigActorUnreplicated : AActor
{
	default SetReplicates(false);
	default SetReplicateMovement(false);

	UPROPERTY()
	int Health = 0;
}
