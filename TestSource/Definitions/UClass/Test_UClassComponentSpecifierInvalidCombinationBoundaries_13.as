// Theme: Definitions.UClass. Isolated compile-fail: two RootComponent default components.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: is RootComponent, but the actor already has root component Root.
// DiagnosticOnly. Do not drop RootComponent from OtherRoot; that would make the program compile.

UCLASS()
class ACoverageUClassDuplicateRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
