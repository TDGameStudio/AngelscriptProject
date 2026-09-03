/**
 * HasAuthority, GetLocalRole and GetRemoteRole queried on a replicated actor, with
 * an unreplicated sibling that runs the same query. The query returns -1 when the
 * local authority checks fail, so C++ can tell "the bindings are visible" apart
 * from "the checks did not hold".
 *
 * @Theme World.Actor
 * @Subject Actor.NetworkRoleQueriesAreVisible
 * @Harness UClass
 * @Tag World.Actor.ActorNetworkRoleQueriesAreVisible
 * @Provenance Theme: World.Actor. WorldStory: HasAuthority / GetLocalRole / GetRemoteRole on a
 * @Provenance replicated actor. Query returns -1 when local authority checks fail.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRoleQueriesAreVisible
 * @Provenance Oracle: CDO QueryRemoteRoleAfterCheckingLocalAuthority matches native GetRemoteRole.
 * @Provenance Extra: unreplicated sibling with SetReplicates(false). FixtureIsolated.
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
