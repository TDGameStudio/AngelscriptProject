// Theme: Definitions.UClass. Isolated compile-fail: Attach parent name does not exist.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Attach parent MissingParent does not exist for DefaultComponent Child.
// DiagnosticOnly. Do not retarget Attach to Root; that would make the program compile.

UCLASS()
class ACoverageUClassMissingAttachParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
