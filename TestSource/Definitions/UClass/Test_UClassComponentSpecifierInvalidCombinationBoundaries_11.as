// Theme: Definitions.UClass. Isolated compile-fail: Attach on a non-scene actor component.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: has a component attach set, but is not a type of scene component.
// DiagnosticOnly. Do not change Logic to USceneComponent; that would make the program compile.

UCLASS()
class UCoverageUClassPlainAttachLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassPlainAttachLogicComponent Logic;
}
