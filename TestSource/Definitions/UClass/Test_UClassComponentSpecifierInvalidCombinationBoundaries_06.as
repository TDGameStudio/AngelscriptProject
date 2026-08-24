// Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent combined with OverrideComponent.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: OverrideComponent and DefaultComponent should not be used simultaneously.
// DiagnosticOnly. Do not drop either specifier; that would make the program compile.

UCLASS()
class ACoverageUClassOverrideAndDefaultActor : AActor
{
	UPROPERTY(DefaultComponent, OverrideComponent=Root)
	USceneComponent Root;
}
