/**
 * @version v1
 * @summary Controller and local-control queries on an unpossessed pawn, collected into one bitmask. C++ spawns the pawn and compares the mask with the native query results. Nothing is recorded until the query runs.
 * @topic World
 */
/**
 * @version root
 * @summary Controller and local-control queries on an unpossessed pawn, collected into one bitmask. C++ spawns the pawn and compares the mask with the native query results. Nothing is recorded until the query runs.
 * @topic Baseline
 */
UCLASS()
class ACoverageNetworkingPawnControllerQueries : APawn
{
	UPROPERTY()
	int LastQueriedMask = 0;

	/**
	 * Collect the six controller and local-control states of an unpossessed pawn into
	 * one bitmask.
	 *
	 * @Kind Observe
	 * @Covers Actor.PawnControllerAndLocalControlQueries
	 * @Inputs none
	 * @Return the mask, with a bit per query that reports the unpossessed value
	 */
	UFUNCTION()
	int QueryUnpossessedPawnControllerState()
	{
		int Mask = 0;

		if (GetController() == null)
		{
			Mask |= 1;
		}
		if (GetPlayerController() == null)
		{
			Mask |= 2;
		}
		if (!IsLocallyControlled())
		{
			Mask |= 4;
		}
		if (!IsPlayerControlled())
		{
			Mask |= 8;
		}
		if (!IsBotControlled())
		{
			Mask |= 16;
		}
		if (GetPlayerState() == null)
		{
			Mask |= 32;
		}

		LastQueriedMask = Mask;
		return Mask;
	}

	/**
	 * Observe that a locally constructed pawn has not been queried.
	 *
	 * @Kind Observe
	 * @Covers Actor.PawnControllerAndLocalControlQueries
	 * @Inputs a pawn whose query has not run
	 * @Return true when LastQueriedMask is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return LastQueriedMask == 0;
	}
}
/** @end */
