// Theme: Feature.DefaultComponent. Isolated compile-fail: RootComponent on a non-scene component.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "has RootComponent set, but is not a type of scene component".
// DiagnosticOnly. Do not change LogicRoot to USceneComponent.

UCLASS()
class UCoverageUClassDefaultComponentLogicRoot : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassDefaultComponentLogicRoot LogicRoot;
}
