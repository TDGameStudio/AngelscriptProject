/**
 * Common engine UCLASS bases from Pawn through LocalPlayerSubsystem. Each
 * generated class is a child of the matching native engine type.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassCommonEngineBaseDeclarations
 * @Harness UClass
 * @Tag Definitions.UClass.UClassCommonEngineBaseDeclarations
 * @Provenance Theme: Definitions.UClass. Positive common engine UCLASS bases (Pawn through LocalPlayerSubsystem).
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassCommonEngineBaseDeclarations
 * @Provenance Oracle: each generated class is a child of the matching native engine type.
 * @Provenance Extra: unset handles are null. DefaultSafe.
 */

UCLASS()
class ACoverageUClassPawn : APawn
{
	/**
	 * Observe that an unset pawn handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset ACoverageUClassPawn handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassPawn Pawn;
		return Pawn == nullptr;
	}
}

UCLASS()
class ACoverageUClassCharacter : ACharacter
{
	/**
	 * Observe that an unset character handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset ACoverageUClassCharacter handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassCharacter Character;
		return Character == nullptr;
	}
}

UCLASS()
class ACoverageUClassPlayerController : APlayerController
{
}

UCLASS()
class ACoverageUClassGameMode : AGameModeBase
{
}

UCLASS()
class ACoverageUClassGameState : AGameStateBase
{
}

UCLASS()
class ACoverageUClassPlayerState : APlayerState
{
}

UCLASS()
class ACoverageUClassHUD : AHUD
{
}

UCLASS()
class UCoverageUClassUserWidget : UUserWidget
{
	/**
	 * Observe that an unset widget handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassUserWidget handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassUserWidget Widget;
		return Widget == nullptr;
	}
}

UCLASS()
class UCoverageUClassWorldSubsystem : UScriptWorldSubsystem
{
	/**
	 * Observe that an unset world-subsystem handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassWorldSubsystem handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassWorldSubsystem Sub;
		return Sub == nullptr;
	}
}

UCLASS()
class UCoverageUClassGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
}

UCLASS()
class UCoverageUClassLocalPlayerSubsystem : UScriptLocalPlayerSubsystem
{
	/**
	 * Observe that an unset local-player-subsystem handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BaseType
	 * @Inputs an unset UCoverageUClassLocalPlayerSubsystem handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassLocalPlayerSubsystem Sub;
		return Sub == nullptr;
	}
}
