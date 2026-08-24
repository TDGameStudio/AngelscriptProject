// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent on a plain UObject.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: was marked as OverrideComponent, but is not a type of component.
// DiagnosticOnly. Do not change Replacement to a component type; that would make the program compile.

UCLASS()
class UCoverageUClassPlainOverrideObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassNonComponentOverrideChildActor : ACoverageUClassNonComponentOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassPlainOverrideObject Replacement;
}
