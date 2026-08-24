// Theme: Definitions.UClass. Isolated compile-fail: RootComponent without DefaultComponent.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: RootComponent can only be specified on DefaultComponents.
// DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.

UCLASS()
class ACoverageUClassRootWithoutDefaultActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
