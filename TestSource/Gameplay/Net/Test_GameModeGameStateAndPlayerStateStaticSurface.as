// Theme: Gameplay.Net. Positive static GameMode / GameState / PlayerState surface.
// C++: AngelscriptCoverageNetworkingTests.cpp::GameModeGameStateAndPlayerStateStaticSurface
// Oracle: three classes compile; RecordPostLogin 1 PlayerController param; RecordLogout 1 Controller.
// Extra: LoginCount default 0; nullptr login/logout do not change count; DisplayName "Player".
// DefaultSafe. Keep UPROPERTY names.

UCLASS(Blueprintable)
class ACoverageNetworkingStaticGameMode : AGameModeBase
{
	UPROPERTY()
	int LoginCount = 0;

	UFUNCTION()
	void RecordPostLogin(APlayerController NewPlayer)
	{
		if (NewPlayer != nullptr)
			LoginCount += 1;
	}

	UFUNCTION()
	void RecordLogout(AController Exiting)
	{
		if (Exiting != nullptr)
			LoginCount -= 1;
	}
}

UCLASS(Blueprintable)
class ACoverageNetworkingStaticGameState : AGameStateBase
{
	UPROPERTY(Replicated)
	int MatchSeconds = 0;

	UPROPERTY(ReplicatedUsing=OnRep_TeamScore)
	int TeamScore = 0;

	UFUNCTION()
	void OnRep_TeamScore()
	{
	}
}

UCLASS(Blueprintable)
class ACoverageNetworkingStaticPlayerState : APlayerState
{
	UPROPERTY(Replicated)
	int ScoreBucket = 0;

	UPROPERTY(ReplicatedUsing=OnRep_DisplayName)
	FString DisplayName = "Player";

	UFUNCTION()
	void OnRep_DisplayName()
	{
	}
}

bool Observe_StaticGameMode_LoginCountDefault(ACoverageNetworkingStaticGameMode Mode)
{
	if (Mode is null)
	{
		throw("Test_GameModeGameStateAndPlayerStateStaticSurface setup: required Mode is null");
	}
	return Mode.LoginCount == 0;
}

bool Observe_StaticGameMode_NullLoginLogoutBoundary(ACoverageNetworkingStaticGameMode Mode)
{
	if (Mode is null)
	{
		throw("Test_GameModeGameStateAndPlayerStateStaticSurface setup: required Mode is null");
	}
	Mode.RecordPostLogin(nullptr);
	Mode.RecordLogout(nullptr);
	return Mode.LoginCount == 0;
}

bool Observe_StaticGameState_Defaults(ACoverageNetworkingStaticGameState State)
{
	if (State is null)
	{
		throw("Test_GameModeGameStateAndPlayerStateStaticSurface setup: required State is null");
	}
	return State.MatchSeconds == 0 && State.TeamScore == 0;
}

bool Observe_StaticPlayerState_DisplayNameDefault(ACoverageNetworkingStaticPlayerState State)
{
	if (State is null)
	{
		throw("Test_GameModeGameStateAndPlayerStateStaticSurface setup: required State is null");
	}
	return State.ScoreBucket == 0 && State.DisplayName == "Player";
}
