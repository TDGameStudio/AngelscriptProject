// Theme: Feature.DefaultComponent. Isolated compile-fail: two RootComponent default components.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "is RootComponent, but the actor already has root component Root".
// DiagnosticOnly. Do not drop the second RootComponent.

UCLASS()
class ACoverageUClassDefaultComponentDuplicateRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
