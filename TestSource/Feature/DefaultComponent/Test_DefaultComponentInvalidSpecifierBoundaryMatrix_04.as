// Theme: Feature.DefaultComponent. Isolated compile-fail: ShowOnActor without DefaultComponent.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "ShowOnActor can only be used on default components in actors".
// DiagnosticOnly. Do not add DefaultComponent.

UCLASS()
class ACoverageUClassDefaultComponentShowOnActorWithoutDefault : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
