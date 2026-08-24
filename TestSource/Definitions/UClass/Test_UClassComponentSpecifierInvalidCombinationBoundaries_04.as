// Theme: Definitions.UClass. Isolated compile-fail: ShowOnActor without DefaultComponent.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: ShowOnActor can only be used on default components in actors.
// DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.

UCLASS()
class ACoverageUClassShowOnActorWithoutDefaultActor : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
