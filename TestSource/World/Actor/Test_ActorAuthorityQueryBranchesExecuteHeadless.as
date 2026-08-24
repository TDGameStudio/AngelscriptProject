// Theme: World.Actor. WorldStory: authority/client role branch mask on a replicated actor.
// C++: AngelscriptCoverageNetworkingTests.cpp::ActorAuthorityQueryBranchesExecuteHeadless
// Oracle: QueryAuthorityRoleMask and VerifyByPath LastRoleMask match native HasAuthority /
// GetLocalRole / GetRemoteRole bits (1/2/4/8).
// Extra: LastRoleMask default 0; unreplicated sibling with SetReplicates(false).
// FixtureIsolated.

UCLASS()
class ACoverageNetworkingAuthorityBranchActor : AActor
{
	default SetReplicates(true);

	UPROPERTY()
	int LastRoleMask = 0;

	UFUNCTION()
	int QueryAuthorityRoleMask()
	{
		int Mask = 0;
		ENetRole LocalRole = GetLocalRole();

		if (HasAuthority())
		{
			Mask |= 1;
		}
		if (LocalRole == ENetRole::ROLE_Authority)
		{
			Mask |= 2;
		}
		if (int(LocalRole) < int(ENetRole::ROLE_Authority))
		{
			Mask |= 4;
		}
		if (GetRemoteRole() == ENetRole::ROLE_None)
		{
			Mask |= 8;
		}

		LastRoleMask = Mask;
		return Mask;
	}
}

UCLASS()
class ACoverageNetworkingAuthorityBranchActorUnreplicated : AActor
{
	default SetReplicates(false);

	UPROPERTY()
	int LastRoleMask = 0;

	UFUNCTION()
	int QueryAuthorityRoleMask()
	{
		int Mask = 0;
		ENetRole LocalRole = GetLocalRole();

		if (HasAuthority())
		{
			Mask |= 1;
		}
		if (LocalRole == ENetRole::ROLE_Authority)
		{
			Mask |= 2;
		}
		if (int(LocalRole) < int(ENetRole::ROLE_Authority))
		{
			Mask |= 4;
		}
		if (GetRemoteRole() == ENetRole::ROLE_None)
		{
			Mask |= 8;
		}

		LastRoleMask = Mask;
		return Mask;
	}
}
