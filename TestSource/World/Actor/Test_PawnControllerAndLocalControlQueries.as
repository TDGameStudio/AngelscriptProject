// Theme: World.Actor. WorldStory: unpossessed pawn controller/local-control queries.
// C++: AngelscriptCoverageNetworkingTests.cpp::PawnControllerAndLocalControlQueries
// Oracle: QueryUnpossessedPawnControllerState mask matches native GetController /
// GetPlayerController / IsLocallyControlled / IsPlayerControlled / IsBotControlled /
// GetPlayerState on the spawned pawn.
// Extra: LastQueriedMask stays 0 until the query runs (empty/false flag).
// Do not spawn from script; C++ fixture spawns the pawn. FixtureIsolated.

UCLASS()
class ACoverageNetworkingPawnControllerQueries : APawn
{
	UPROPERTY()
	int LastQueriedMask = 0;

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
}
