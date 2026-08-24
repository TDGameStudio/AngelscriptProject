// Theme: Definitions.UClass. Positive game-framework UCLASS methods and object references.
// C++: AngelscriptCoverageUClassTests.cpp::UClassGameFrameworkReferenceSurface
// Oracle: generated classes inherit Character/PlayerState/PlayerController/GameModeBase/GameStateBase.
// Script oracle: ReadHealth=44; BuildPlayerLabel("X")="CoveragePlayer_X"; RoutePlayers(null,null)=0.
// Extra: empty suffix; both-null RoutePlayers; empty ScriptPlayerStates. DefaultSafe.

UCLASS()
class ACoverageUClassFrameworkCharacter : ACharacter
{
	UPROPERTY()
	int Health = 44;

	UFUNCTION()
	int ReadHealth()
	{
		return Health;
	}
}

UCLASS()
class ACoverageUClassFrameworkPlayerState : APlayerState
{
	UPROPERTY()
	FString PublicName = "CoveragePlayer";

	UFUNCTION()
	FString BuildPlayerLabel(const FString&in Suffix)
	{
		return PublicName + "_" + Suffix;
	}
}

UCLASS()
class ACoverageUClassFrameworkController : APlayerController
{
	UPROPERTY()
	ACoverageUClassFrameworkCharacter CharacterRef;

	UPROPERTY()
	APlayerState PlayerStateRef;

	UPROPERTY()
	TSubclassOf<ACharacter> CharacterClass = ACoverageUClassFrameworkCharacter::StaticClass();

	UFUNCTION()
	void AssignRefs(ACoverageUClassFrameworkCharacter InCharacter, APlayerState InPlayerState)
	{
		CharacterRef = InCharacter;
		PlayerStateRef = InPlayerState;
	}
}

UCLASS()
class ACoverageUClassFrameworkGameMode : AGameModeBase
{
	UPROPERTY()
	TSubclassOf<APawn> PawnClassRef = ACoverageUClassFrameworkCharacter::StaticClass();

	UFUNCTION()
	int RoutePlayers(APlayerController NewPlayer, AController LeavingController)
	{
		return (NewPlayer != nullptr ? 10 : 0) + (LeavingController != nullptr ? 1 : 0);
	}
}

UCLASS()
class ACoverageUClassFrameworkGameState : AGameStateBase
{
	UPROPERTY()
	TArray<APlayerState> ScriptPlayerStates;

	UFUNCTION()
	void AddScriptPlayerState(APlayerState State)
	{
		ScriptPlayerStates.Add(State);
	}
}

int Observe_FrameworkCharacter_ReadHealthDefault(ACoverageUClassFrameworkCharacter Character)
{
	if (Character == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkCharacter is null");
	}
	return Character.ReadHealth();
}

FString Observe_FrameworkPlayerState_BuildLabelNominal(ACoverageUClassFrameworkPlayerState State)
{
	if (State == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkPlayerState is null");
	}
	return State.BuildPlayerLabel("X");
}

FString Observe_FrameworkPlayerState_BuildLabelEmptySuffix(ACoverageUClassFrameworkPlayerState State)
{
	if (State == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkPlayerState is null");
	}
	return State.BuildPlayerLabel("");
}

int Observe_FrameworkGameMode_RoutePlayersBothNull(ACoverageUClassFrameworkGameMode Mode)
{
	if (Mode == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkGameMode is null");
	}
	return Mode.RoutePlayers(nullptr, nullptr);
}

bool Observe_FrameworkController_CharacterRefDefaultNull(ACoverageUClassFrameworkController Controller)
{
	if (Controller == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkController is null");
	}
	return Controller.CharacterRef == nullptr;
}

bool Observe_FrameworkGameState_PlayerStatesEmptyDefault(ACoverageUClassFrameworkGameState State)
{
	if (State == nullptr)
	{
		throw("TS-DEF-0139 setup: required ACoverageUClassFrameworkGameState is null");
	}
	return State.ScriptPlayerStates.Num() == 0;
}
