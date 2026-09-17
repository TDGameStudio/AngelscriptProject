/**
 * @version v1
 * @summary Character/GameMode/PlayerState/GameState event override surface. K2_OnStartCrouch/OnEndCrouch/UpdateCustomMovement exist; OnRep_CoverageFlag is generated. Keep bCoverageFlag and OnRep_CoverageFlag.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Character/GameMode/PlayerState/GameState event override surface. K2_OnStartCrouch/OnEndCrouch/UpdateCustomMovement exist; OnRep_CoverageFlag is generated. Keep bCoverageFlag and OnRep_CoverageFlag.
 * @topic Baseline
 */
UCLASS()
class ACoverageUClassEventCharacter : ACharacter
{
	/**
	 * WorldStory: OnStartCrouch is the character crouch-start override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param HalfHeightAdjust Capsule half-height adjust
	 * @Param ScaledHalfHeightAdjust Scaled half-height adjust
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnStartCrouch(float HalfHeightAdjust, float ScaledHalfHeightAdjust)
	{
	}

	/**
	 * WorldStory: OnEndCrouch is the character crouch-end override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param HalfHeightAdjust Capsule half-height adjust
	 * @Param ScaledHalfHeightAdjust Scaled half-height adjust
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnEndCrouch(float HalfHeightAdjust, float ScaledHalfHeightAdjust)
	{
	}

	/**
	 * WorldStory: UpdateCustomMovement is the custom-movement override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param DeltaTime Frame delta
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void UpdateCustomMovement(float DeltaTime)
	{
	}

	/**
	 * Observe that an unset character handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs an unset ACoverageUClassEventCharacter handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassEventCharacter Character;
		return Character == nullptr;
	}

	/**
	 * Observe empty crouch/movement overrides at zero values.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs OnStartCrouch(0,0); OnEndCrouch(0,0); UpdateCustomMovement(0)
	 * @Return 0
	 * @Boundary zero values
	 */
	UFUNCTION()
	int OnStartCrouchZeroBoundary()
	{
		OnStartCrouch(0.0f, 0.0f);
		OnEndCrouch(0.0f, 0.0f);
		UpdateCustomMovement(0.0f);
		return 0;
	}
}

UCLASS()
class ACoverageUClassEventGameMode : AGameModeBase
{
	/**
	 * WorldStory: OnPostLogin is the post-login override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param NewPlayer Logging-in player
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnPostLogin(APlayerController NewPlayer)
	{
	}

	/**
	 * WorldStory: OnLogout is the logout override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param ExitingController Leaving controller
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnLogout(AController ExitingController)
	{
	}

	/**
	 * WorldStory: OnChangeName is the name-change override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param Other Controller whose name changed
	 * @Param NewName New player name
	 * @Param bNameChange Whether the name actually changed
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnChangeName(AController Other, const FString&in NewName, bool bNameChange)
	{
	}

	/**
	 * WorldStory: OnRestartPlayer is the restart-player override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param NewPlayer Restarted controller
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnRestartPlayer(AController NewPlayer)
	{
	}

	/**
	 * WorldStory: OnSwapPlayerControllers is the swap-controllers override.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param OldPC Previous controller
	 * @Param NewPC Replacement controller
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OnSwapPlayerControllers(APlayerController OldPC, APlayerController NewPC)
	{
	}

	/**
	 * Observe that an unset game-mode handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs an unset ACoverageUClassEventGameMode handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassEventGameMode Mode;
		return Mode == nullptr;
	}
}

UCLASS()
class ACoverageUClassEventPlayerState : APlayerState
{
	/**
	 * WorldStory: OverrideWith copies from an old player state.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param OldPlayerState Previous player state
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void OverrideWith(APlayerState OldPlayerState)
	{
	}

	/**
	 * WorldStory: CopyProperties copies into a new player state.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.GameFramework
	 * @Param NewPlayerState Destination player state
	 * @Inputs none
	 * @Return empty override completes
	 */
	UFUNCTION(BlueprintOverride)
	void CopyProperties(APlayerState NewPlayerState)
	{
	}

	/**
	 * Observe that an unset player-state handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs an unset ACoverageUClassEventPlayerState handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassEventPlayerState State;
		return State == nullptr;
	}
}

UCLASS()
class ACoverageUClassEventGameState : AGameStateBase
{
	UPROPERTY(ReplicatedUsing=OnRep_CoverageFlag)
	bool bCoverageFlag = false;

	/**
	 * Observe OnRep_CoverageFlag: the generated rep notify.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs none
	 * @Return empty notify completes
	 */
	UFUNCTION()
	void OnRep_CoverageFlag()
	{
	}

	/**
	 * Observe the bCoverageFlag default.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs a freshly constructed game state
	 * @Return true when bCoverageFlag is false
	 * @Boundary default false
	 */
	UFUNCTION()
	bool CoverageFlagDefaultFalse()
	{
		return bCoverageFlag == false;
	}

	/**
	 * Observe that an empty OnRep_CoverageFlag completes.
	 *
	 * @Kind Observe
	 * @Covers UClass.GameFramework
	 * @Inputs OnRep_CoverageFlag()
	 * @Return 0
	 */
	UFUNCTION()
	int OnRepEmptyCompletes()
	{
		OnRep_CoverageFlag();
		return 0;
	}
}
/** @end */
