/**
 * Controller and local-control queries on an unpossessed pawn, collected into one
 * bitmask. C++ spawns the pawn and compares the mask with the native query results.
 * Nothing is recorded until the query runs.
 *
 * @Theme World.Actor
 * @Subject Actor.PawnControllerAndLocalControlQueries
 * @Harness UClass
 * @Tag World.Actor.PawnControllerAndLocalControlQueries
 * @Provenance Theme: World.Actor. WorldStory: unpossessed pawn controller/local-control queries.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::PawnControllerAndLocalControlQueries
 * @Provenance Oracle: QueryUnpossessedPawnControllerState mask matches native GetController /
 * @Provenance GetPlayerController / IsLocallyControlled / IsPlayerControlled / IsBotControlled /
 * @Provenance GetPlayerState on the spawned pawn.
 * @Provenance Extra: LastQueriedMask stays 0 until the query runs (empty/false flag).
 * @Provenance Do not spawn from script; C++ fixture spawns the pawn. FixtureIsolated.
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
