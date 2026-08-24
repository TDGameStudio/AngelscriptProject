// Theme: Feature.DefaultComponent. Isolated compile-fail: Attach parent does not exist.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "Attach parent MissingParent does not exist for DefaultComponent Child".
// DiagnosticOnly. Do not declare MissingParent.

UCLASS()
class ACoverageUClassDefaultComponentMissingAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
