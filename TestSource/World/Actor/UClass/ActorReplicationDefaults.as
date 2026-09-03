/**
 * Default SetReplicates and SetReplicateMovement applied at instance construction,
 * with Health marked Replicated. C++ spawns the instance and verifies both flags and
 * the health value. The unreplicated sibling is the false/empty boundary.
 *
 * @Theme World.Actor
 * @Subject Actor.ReplicationDefaults
 * @Harness UClass
 * @Tag World.Actor.ActorReplicationDefaults
 * @Provenance Theme: World.Actor. WorldStory: default SetReplicates/SetReplicateMovement
 * @Provenance apply at instance construction; Health is CPF_Net.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ActorReplicationDefaults
 * @Provenance Oracle: spawned instance GetIsReplicated true, IsReplicatingMovement true, Health=100.
 * @Provenance Extra: unreplicated sibling Health 0 is the false/empty boundary. FixtureIsolated.
 */

UCLASS()
class ACoverageNetworkingConfigActor : AActor
{
	default SetReplicates(true);
	default SetReplicateMovement(true);

	UPROPERTY(Replicated)
	int Health = 100;
}

/**
 * The unreplicated sibling, whose zeroed health is the false/empty boundary that
 * C++ compares against.
 *
 * @Covers Actor.ReplicationDefaults
 * @Inputs none
 * @Return an actor with replication and movement replication off and Health 0
 * @Boundary unreplicated defaults
 */
UCLASS()
class ACoverageNetworkingConfigActorUnreplicated : AActor
{
	default SetReplicates(false);
	default SetReplicateMovement(false);

	UPROPERTY()
	int Health = 0;
}
