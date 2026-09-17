/**
 * @version v1
 * @summary Default SetReplicates and SetReplicateMovement applied at instance construction, with Health marked Replicated. C++ spawns the instance and verifies both flags and the health value. The unreplicated sibling is the.
 * @topic World
 */
/**
 * @version root
 * @summary Default SetReplicates and SetReplicateMovement applied at instance construction, with Health marked Replicated. C++ spawns the instance and verifies both flags and the health value. The unreplicated sibling is the.
 * @topic Baseline
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
/** @end */
