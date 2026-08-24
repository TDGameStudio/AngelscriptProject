// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent target missing on the base.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: could not find component MissingScene in base class to override.
// DiagnosticOnly. Do not retarget OverrideComponent to Root; that would make the program compile.

UCLASS()
class ACoverageUClassMissingOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassMissingOverrideChildActor : ACoverageUClassMissingOverrideBaseActor
{
	UPROPERTY(OverrideComponent=MissingScene)
	USceneComponent Replacement;
}
