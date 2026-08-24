// Theme: Feature.DefaultComponent. Isolated compile-fail: RootComponent without DefaultComponent.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "RootComponent can only be specified on DefaultComponents".
// DiagnosticOnly. Do not add DefaultComponent.

UCLASS()
class ACoverageUClassDefaultComponentRootWithoutDefault : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
