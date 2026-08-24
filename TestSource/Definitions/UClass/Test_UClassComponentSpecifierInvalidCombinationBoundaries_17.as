// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent uses an Abstract scene class.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: was marked as OverrideComponent, but the component class is abstract and cannot be used.
// DiagnosticOnly. Do not drop Abstract; that would make the program compile.

UCLASS(Abstract)
class UCoverageUClassAbstractOverrideSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassAbstractOverrideChildActor : ACoverageUClassAbstractOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassAbstractOverrideSceneComponent Replacement;
}
