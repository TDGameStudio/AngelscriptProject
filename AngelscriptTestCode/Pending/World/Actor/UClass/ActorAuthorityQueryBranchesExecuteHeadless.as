/**
 * @version v1
 * @summary Authority and role branch mask collected into one integer on a replicated actor, with an unreplicated sibling that runs the same branches. C++ runs QueryAuthorityRoleMask on both and compares the mask with the native.
 * @topic World
 */
/**
 * @version root
 * @summary Authority and role branch mask collected into one integer on a replicated actor, with an unreplicated sibling that runs the same branches. C++ runs QueryAuthorityRoleMask on both and compares the mask with the native.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingAuthorityBranchActor : AActor
{
	default SetReplicates(true);

	UPROPERTY()
	int LastRoleMask = 0;

	/**
	 * Collect the four authority and role branches into one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
	 * @Inputs none
	 * @Return the mask, with bit 1 for HasAuthority, 2 for the authority local role,
	 * 4 for a local role below authority and 8 for a None remote role
	 */
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

/**
 * The unreplicated sibling that runs the same branches with replication off, so
 * C++ can compare the two masks.
 *
 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
 * @Inputs none
 * @Return an actor identical to the replicated one except for SetReplicates(false)
 */
UCLASS()
class ACoverageNetworkingAuthorityBranchActorUnreplicated : AActor
{
	default SetReplicates(false);

	UPROPERTY()
	int LastRoleMask = 0;

	/**
	 * Collect the four authority and role branches into one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.AuthorityQueryBranchesExecuteHeadless
	 * @Inputs none
	 * @Return the mask, with bit 1 for HasAuthority, 2 for the authority local role,
	 * 4 for a local role below authority and 8 for a None remote role
	 */
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
/** @end */
