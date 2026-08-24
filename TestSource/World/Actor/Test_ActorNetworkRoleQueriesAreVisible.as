// Theme: World.Actor. WorldStory: HasAuthority / GetLocalRole / GetRemoteRole on a
// replicated actor. Query returns -1 when local authority checks fail.
// C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRoleQueriesAreVisible
// Oracle: CDO QueryRemoteRoleAfterCheckingLocalAuthority matches native GetRemoteRole.
// Extra: unreplicated sibling with SetReplicates(false). FixtureIsolated.

UCLASS()
class ACoverageNetworkingRoleQueryActor : AActor
{
	default SetReplicates(true);

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

UCLASS()
class ACoverageNetworkingRoleQueryActorUnreplicated : AActor
{
	default SetReplicates(false);

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
