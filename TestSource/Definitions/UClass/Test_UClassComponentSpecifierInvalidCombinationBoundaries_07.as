// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent also marked RootComponent.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: RootComponent can only be specified on DefaultComponents.
// DiagnosticOnly. Do not drop RootComponent from the override; that would make the program compile.

UCLASS()
class ACoverageUClassOverrideWithRootBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassOverrideWithRootChildActor : ACoverageUClassOverrideWithRootBaseActor
{
	UPROPERTY(OverrideComponent=Root, RootComponent)
	USceneComponent Replacement;
}
