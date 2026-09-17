/**
 * @version v1
 * @summary HasAuthority, GetLocalRole and GetRemoteRole queried on a replicated actor, with an unreplicated sibling that runs the same query. The query returns -1 when the local authority checks fail, so C++ can tell "the bindings.
 * @topic World
 */
/**
 * @version root
 * @summary HasAuthority, GetLocalRole and GetRemoteRole queried on a replicated actor, with an unreplicated sibling that runs the same query. The query returns -1 when the local authority checks fail, so C++ can tell "the bindings.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingRoleQueryActor : AActor
{
	default SetReplicates(true);

	/**
	 * Return the remote role, but only after the local authority checks hold.
	 *
	 * @Kind Observe
	 * @Covers Actor.NetworkRoleQueriesAreVisible
	 * @Inputs none
	 * @Return the remote role as an integer, or -1 when any local authority check fails
	 */
	UFUNCTION()
	int QueryRemoteRoleAfterCheckingLocalAuthority()
	{
		ENetRole LocalRole = GetLocalRole();
		if (!HasAuthority()
			|| LocalRole != ENetRole::ROLE_Authority
			|| int(LocalRole) <= int(ENetRole::ROLE_AutonomousProxy))
		{
			return -1;
		}

		return int(GetRemoteRole());
	}
}

/**
 * The unreplicated sibling that runs the same query with replication off, so C++
 * can compare the two results.
 *
 * @Covers Actor.NetworkRoleQueriesAreVisible
 * @Inputs none
 * @Return an actor identical to the replicated one except for SetReplicates(false)
 */
UCLASS()
class ACoverageNetworkingRoleQueryActorUnreplicated : AActor
{
	default SetReplicates(false);

	/**
	 * Return the remote role, but only after the local authority checks hold.
	 *
	 * @Kind Observe
	 * @Covers Actor.NetworkRoleQueriesAreVisible
	 * @Inputs none
	 * @Return the remote role as an integer, or -1 when any local authority check fails
	 */
	UFUNCTION()
	int QueryRemoteRoleAfterCheckingLocalAuthority()
	{
		ENetRole LocalRole = GetLocalRole();
		if (!HasAuthority()
			|| LocalRole != ENetRole::ROLE_Authority
			|| int(LocalRole) <= int(ENetRole::ROLE_AutonomousProxy))
		{
			return -1;
		}

		return int(GetRemoteRole());
	}
}
/** @end */
