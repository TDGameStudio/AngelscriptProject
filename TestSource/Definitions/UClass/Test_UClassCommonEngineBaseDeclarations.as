// Theme: Definitions.UClass. Positive common engine UCLASS bases (Pawn through LocalPlayerSubsystem).
// C++: AngelscriptCoverageUClassTests.cpp::UClassCommonEngineBaseDeclarations
// Oracle: each generated class is a child of the matching native engine type.
// Extra: unset handles are null. DefaultSafe.

UCLASS()
class ACoverageUClassPawn : APawn
{
}

UCLASS()
class ACoverageUClassCharacter : ACharacter
{
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
}

UCLASS()
class UCoverageUClassWorldSubsystem : UScriptWorldSubsystem
{
}

UCLASS()
class UCoverageUClassGameInstanceSubsystem : UScriptGameInstanceSubsystem
{
}

UCLASS()
class UCoverageUClassLocalPlayerSubsystem : UScriptLocalPlayerSubsystem
{
}

bool Observe_CommonEnginePawn_EmptyDefaultIsNull()
{
	ACoverageUClassPawn Pawn;
	return Pawn == nullptr;
}

bool Observe_CommonEngineCharacter_EmptyDefaultIsNull()
{
	ACoverageUClassCharacter Character;
	return Character == nullptr;
}

bool Observe_CommonEngineWidget_EmptyDefaultIsNull()
{
	UCoverageUClassUserWidget Widget;
	return Widget == nullptr;
}

bool Observe_CommonEngineWorldSubsystem_EmptyDefaultIsNull()
{
	UCoverageUClassWorldSubsystem Sub;
	return Sub == nullptr;
}

bool Observe_CommonEngineLocalPlayerSubsystem_EmptyDefaultIsNull()
{
	UCoverageUClassLocalPlayerSubsystem Sub;
	return Sub == nullptr;
}
