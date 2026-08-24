// Theme: Containers.TArray. WorldStory: GameState.PlayerArray and PlayerState identity.
// C++ compiles the actor and inspects PlayerArray inner class. Mask bits 1/2/4.
// Extra: null GameState/PlayerState yields 0. FixtureIsolated.

UCLASS()
class ACoverageNetworkingGameStatePlayerSurface : AActor
{
	UFUNCTION()
	int QueryGameStateAndPlayerState(AGameStateBase GameState, APlayerState PlayerState)
	{
		int Mask = 0;
		if (GameState != nullptr && GameState.PlayerArray.Num() >= 0)
		{
			Mask |= 1;
		}
		if (PlayerState != nullptr)
		{
			if (PlayerState.GetPlayerName().Len() >= 0)
			{
				Mask |= 2;
			}
			if (PlayerState.GetScore() >= 0.0f)
			{
				Mask |= 4;
			}
		}
		return Mask;
	}
}

int Observe_NullFixturesYieldZero(ACoverageNetworkingGameStatePlayerSurface Surface)
{
	if (Surface is null)
	{
		throw("Test_GameStatePlayerArrayAndPlayerStateIdentitySurface setup: required Surface is null");
	}
	AGameStateBase NullState;
	APlayerState NullPlayer;
	return Surface.QueryGameStateAndPlayerState(NullState, NullPlayer);
}
