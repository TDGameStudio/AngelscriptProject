// Theme: Definitions.UClass. Positive Character/GameMode/PlayerState/GameState event override surface.
// C++: AngelscriptCoverageUClassTests.cpp::UClassGameFrameworkEventFunctionSurface
// Oracle: K2_OnStartCrouch/OnEndCrouch/UpdateCustomMovement exist; OnRep_CoverageFlag is generated.
// Extra: unset handles are null; bCoverageFlag default false; empty OnStartCrouch completes. DefaultSafe.

UCLASS()
class ACoverageUClassEventCharacter : ACharacter
{
	UFUNCTION(BlueprintOverride)
	void OnStartCrouch(float HalfHeightAdjust, float ScaledHalfHeightAdjust)
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnEndCrouch(float HalfHeightAdjust, float ScaledHalfHeightAdjust)
	{
	}

	UFUNCTION(BlueprintOverride)
	void UpdateCustomMovement(float DeltaTime)
	{
	}
}

UCLASS()
class ACoverageUClassEventGameMode : AGameModeBase
{
	UFUNCTION(BlueprintOverride)
	void OnPostLogin(APlayerController NewPlayer)
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnLogout(AController ExitingController)
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnChangeName(AController Other, const FString&in NewName, bool bNameChange)
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnRestartPlayer(AController NewPlayer)
	{
	}

	UFUNCTION(BlueprintOverride)
	void OnSwapPlayerControllers(APlayerController OldPC, APlayerController NewPC)
	{
	}
}

UCLASS()
class ACoverageUClassEventPlayerState : APlayerState
{
	UFUNCTION(BlueprintOverride)
	void OverrideWith(APlayerState OldPlayerState)
	{
	}

	UFUNCTION(BlueprintOverride)
	void CopyProperties(APlayerState NewPlayerState)
	{
	}
}

UCLASS()
class ACoverageUClassEventGameState : AGameStateBase
{
	UPROPERTY(ReplicatedUsing=OnRep_CoverageFlag)
	bool bCoverageFlag = false;

	UFUNCTION()
	void OnRep_CoverageFlag()
	{
	}
}

bool Observe_EventCharacter_EmptyDefaultIsNull()
{
	ACoverageUClassEventCharacter Character;
	return Character == nullptr;
}

int Observe_EventCharacter_OnStartCrouchZeroBoundary(ACoverageUClassEventCharacter Character)
{
	if (Character == nullptr)
	{
		throw("TS-DEF-0156 setup: required ACoverageUClassEventCharacter is null");
	}
	Character.OnStartCrouch(0.0f, 0.0f);
	Character.OnEndCrouch(0.0f, 0.0f);
	Character.UpdateCustomMovement(0.0f);
	return 0;
}

bool Observe_EventGameState_CoverageFlagDefaultFalse(ACoverageUClassEventGameState State)
{
	if (State == nullptr)
	{
		throw("TS-DEF-0156 setup: required ACoverageUClassEventGameState is null");
	}
	return State.bCoverageFlag == false;
}

int Observe_EventGameState_OnRepEmptyCompletes(ACoverageUClassEventGameState State)
{
	if (State == nullptr)
	{
		throw("TS-DEF-0156 setup: required ACoverageUClassEventGameState is null");
	}
	State.OnRep_CoverageFlag();
	return 0;
}

bool Observe_EventGameMode_EmptyDefaultIsNull()
{
	ACoverageUClassEventGameMode Mode;
	return Mode == nullptr;
}

bool Observe_EventPlayerState_EmptyDefaultIsNull()
{
	ACoverageUClassEventPlayerState State;
	return State == nullptr;
}
