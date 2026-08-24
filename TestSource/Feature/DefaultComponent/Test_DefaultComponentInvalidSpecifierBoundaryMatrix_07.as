// Theme: Feature.DefaultComponent. Isolated compile-fail: Attach on a non-scene component.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "has a component attach set, but is not a type of scene component".
// DiagnosticOnly. Do not change Logic to USceneComponent.

UCLASS()
class UCoverageUClassDefaultComponentLogicAttach : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneAttach : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassDefaultComponentLogicAttach Logic;
}
