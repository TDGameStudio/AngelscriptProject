/**
 * Game-framework UCLASS methods and object references. Generated classes
 * inherit Character/PlayerState/PlayerController/GameModeBase/GameStateBase.
 * ReadHealth is 44; BuildPlayerLabel("X") is "CoveragePlayer_X";
 * RoutePlayers(null,null) is 0. Keep those UFUNCTION names.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassGameFrameworkReferenceSurface
 * @Harness UClass
 * @Tag Definitions.UClass.UClassGameFrameworkReferenceSurface
 * @Provenance Theme: Definitions.UClass. Positive game-framework UCLASS methods and object references.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassGameFrameworkReferenceSurface
 * @Provenance Oracle: generated classes inherit Character/PlayerState/PlayerController/GameModeBase/GameStateBase.
 * @Provenance Script oracle: ReadHealth=44; BuildPlayerLabel("X")="CoveragePlayer_X"; RoutePlayers(null,null)=0.
 * @Provenance Extra: empty suffix; both-null RoutePlayers; empty ScriptPlayerStates. DefaultSafe.
 */

UCLASS()
class ACoverageUClassFrameworkCharacter : ACharacter
{
	UPROPERTY()
	int Health = 44;

	/**
	 * Observe ReadHealth: it returns Health.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs Health
	 * @Return Health
	 */
	UFUNCTION()
	int ReadHealth()
	{
		return Health;
	}

	/**
	 * Observe the ReadHealth default.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs a freshly constructed character
	 * @Return ReadHealth()
	 */
	UFUNCTION()
	int ReadHealthDefault()
	{
		return ReadHealth();
	}
}

UCLASS()
class ACoverageUClassFrameworkPlayerState : APlayerState
{
	UPROPERTY()
	FString PublicName = "CoveragePlayer";

	/**
	 * Observe BuildPlayerLabel: it concatenates PublicName, underscore, and Suffix.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Param Suffix Trailing fragment
	 * @Inputs PublicName + "_" + Suffix
	 * @Return the concatenated label
	 */
	UFUNCTION()
	FString BuildPlayerLabel(const FString&in Suffix)
	{
		return PublicName + "_" + Suffix;
	}

	/**
	 * Observe BuildPlayerLabel("X").
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs BuildPlayerLabel("X")
	 * @Return "CoveragePlayer_X"
	 */
	UFUNCTION()
	FString BuildLabelNominal()
	{
		return BuildPlayerLabel("X");
	}

	/**
	 * Observe BuildPlayerLabel("").
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs BuildPlayerLabel("")
	 * @Return "CoveragePlayer_"
	 * @Boundary empty suffix
	 */
	UFUNCTION()
	FString BuildLabelEmptySuffix()
	{
		return BuildPlayerLabel("");
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

	/**
	 * Observe AssignRefs: it stores character and player-state handles.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Param InCharacter Character handle
	 * @Param InPlayerState Player-state handle
	 * @Inputs InCharacter, InPlayerState
	 * @Return CharacterRef and PlayerStateRef updated
	 */
	UFUNCTION()
	void AssignRefs(ACoverageUClassFrameworkCharacter InCharacter, APlayerState InPlayerState)
	{
		CharacterRef = InCharacter;
		PlayerStateRef = InPlayerState;
	}

	/**
	 * Observe that CharacterRef defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs a freshly constructed controller
	 * @Return true when CharacterRef is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool CharacterRefDefaultNull()
	{
		return CharacterRef == nullptr;
	}
}

UCLASS()
class ACoverageUClassFrameworkGameMode : AGameModeBase
{
	UPROPERTY()
	TSubclassOf<APawn> PawnClassRef = ACoverageUClassFrameworkCharacter::StaticClass();

	/**
	 * Observe RoutePlayers: it scores a new player as 10 and a leaving controller as 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Param NewPlayer Incoming player
	 * @Param LeavingController Leaving controller
	 * @Inputs NewPlayer, LeavingController
	 * @Return 10 if NewPlayer is non-null plus 1 if LeavingController is non-null
	 */
	UFUNCTION()
	int RoutePlayers(APlayerController NewPlayer, AController LeavingController)
	{
		int Score = 0;
		if (NewPlayer != nullptr)
		{
			Score += 10;
		}
		if (LeavingController != nullptr)
		{
			Score += 1;
		}
		return Score;
	}

	/**
	 * Observe RoutePlayers(nullptr, nullptr).
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs RoutePlayers(nullptr, nullptr)
	 * @Return 0
	 * @Boundary both null
	 */
	UFUNCTION()
	int RoutePlayersBothNull()
	{
		return RoutePlayers(nullptr, nullptr);
	}
}

UCLASS()
class ACoverageUClassFrameworkGameState : AGameStateBase
{
	UPROPERTY()
	TArray<APlayerState> ScriptPlayerStates;

	/**
	 * Observe AddScriptPlayerState: it appends a player state.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Param State Player state to append
	 * @Inputs ScriptPlayerStates.Add(State)
	 * @Return ScriptPlayerStates grows by one
	 */
	UFUNCTION()
	void AddScriptPlayerState(APlayerState State)
	{
		ScriptPlayerStates.Add(State);
	}

	/**
	 * Observe that ScriptPlayerStates defaults to empty.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs a freshly constructed game state
	 * @Return true when Num() is 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool PlayerStatesEmptyDefault()
	{
		return ScriptPlayerStates.Num() == 0;
	}
}
