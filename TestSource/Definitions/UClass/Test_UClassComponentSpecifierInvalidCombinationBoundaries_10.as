// Theme: Definitions.UClass. Isolated compile-fail: RootComponent on a non-scene actor component.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: has RootComponent set, but is not a type of scene component.
// DiagnosticOnly. Do not change RootLogic to USceneComponent; that would make the program compile.

UCLASS()
class UCoverageUClassPlainRootLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassPlainRootLogicComponent RootLogic;
}
