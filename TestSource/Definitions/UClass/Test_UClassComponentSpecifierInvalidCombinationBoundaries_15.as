// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent type does not inherit the base component.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: type does not inherit from the base class's.
// DiagnosticOnly. Do not replace USceneComponent with UStaticMeshComponent; that would make the program compile.

UCLASS()
class ACoverageUClassOverrideWrongTypeBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;
}

UCLASS()
class ACoverageUClassOverrideWrongTypeChildActor : ACoverageUClassOverrideWrongTypeBaseActor
{
	UPROPERTY(OverrideComponent=Mesh)
	USceneComponent Replacement;
}
