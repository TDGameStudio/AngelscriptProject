/**
 * Static GameMode, GameState and PlayerState surfaces. C++ compiles the three classes
 * and checks RecordPostLogin, RecordLogout and the replicated fields, so those names
 * are part of the contract and are kept verbatim. The observers cover LoginCount 0,
 * null login/logout and the DisplayName default.
 *
 * @Theme Gameplay.Net
 * @Subject Net.GameModeGameStateAndPlayerStateStaticSurface
 * @Harness UClass
 * @Tag Gameplay.Net.GameModeGameStateAndPlayerStateStaticSurface
 * @Provenance Theme: Gameplay.Net. Positive static GameMode / GameState / PlayerState surface.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::GameModeGameStateAndPlayerStateStaticSurface
 * @Provenance Oracle: three classes compile; RecordPostLogin 1 PlayerController param; RecordLogout 1 Controller.
 * @Provenance Extra: LoginCount default 0; nullptr login/logout do not change count; DisplayName "Player".
 * @Provenance DefaultSafe. Keep UPROPERTY names.
 */

UCLASS(Blueprintable)
class ACoverageNetworkingStaticGameMode : AGameModeBase
{
	UPROPERTY()
	int LoginCount = 0;

	/**
	 * Increment LoginCount when the joining player is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs a player controller, which may be null
	 * @Return nothing; LoginCount increases when NewPlayer is non-null
	 * @Param NewPlayer the joining player
	 */
	UFUNCTION()
	void RecordPostLogin(APlayerController NewPlayer)
	{
		if (NewPlayer != nullptr)
		{
			LoginCount += 1;
		}
	}

	/**
	 * Decrement LoginCount when the exiting controller is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs a controller, which may be null
	 * @Return nothing; LoginCount decreases when Exiting is non-null
	 * @Param Exiting the leaving controller
	 */
	UFUNCTION()
	void RecordLogout(AController Exiting)
	{
		if (Exiting != nullptr)
		{
			LoginCount -= 1;
		}
	}

	/**
	 * Observe that an untouched game mode keeps LoginCount at 0.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs none
	 * @Return true when LoginCount is 0
	 * @Boundary declared default
	 */
	UFUNCTION()
	bool LoginCountDefault()
	{
		return LoginCount == 0;
	}

	/**
	 * Observe that null login and logout leave LoginCount at 0.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs two null arguments
	 * @Return true when LoginCount is still 0
	 * @Boundary null login/logout
	 */
	UFUNCTION()
	bool NullLoginLogoutBoundary()
	{
		RecordPostLogin(nullptr);
		RecordLogout(nullptr);
		return LoginCount == 0;
	}
}

/**
 * The static GameState sibling with replicated match seconds and a RepNotify team
 * score.
 *
 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
 * @Inputs none
 * @Return a game state with MatchSeconds 0 and TeamScore 0
 */
UCLASS(Blueprintable)
class ACoverageNetworkingStaticGameState : AGameStateBase
{
	UPROPERTY(Replicated)
	int MatchSeconds = 0;

	UPROPERTY(ReplicatedUsing=OnRep_TeamScore)
	int TeamScore = 0;

	/**
	 * RepNotify for TeamScore; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_TeamScore()
	{
	}

	/**
	 * Observe that an untouched game state keeps MatchSeconds and TeamScore at 0.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs none
	 * @Return true when both integers are 0
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (MatchSeconds != 0)
		{
			return false;
		}
		return TeamScore == 0;
	}
}

/**
 * The static PlayerState sibling with a replicated score bucket and DisplayName.
 *
 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
 * @Inputs none
 * @Return a player state with ScoreBucket 0 and DisplayName "Player"
 */
UCLASS(Blueprintable)
class ACoverageNetworkingStaticPlayerState : APlayerState
{
	UPROPERTY(Replicated)
	int ScoreBucket = 0;

	UPROPERTY(ReplicatedUsing=OnRep_DisplayName)
	FString DisplayName = "Player";

	/**
	 * RepNotify for DisplayName; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_DisplayName()
	{
	}

	/**
	 * Observe that an untouched player state keeps ScoreBucket 0 and DisplayName Player.
	 *
	 * @Kind Observe
	 * @Covers Net.GameModeGameStateAndPlayerStateStaticSurface
	 * @Inputs none
	 * @Return true when ScoreBucket is 0 and DisplayName is Player
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DisplayNameDefault()
	{
		if (ScoreBucket != 0)
		{
			return false;
		}
		return DisplayName == "Player";
	}
}
