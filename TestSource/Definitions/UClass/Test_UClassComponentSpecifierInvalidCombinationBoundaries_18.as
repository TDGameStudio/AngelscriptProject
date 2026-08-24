// Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent uses an Abstract scene class.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: was marked as DefaultComponent, but the component class is abstract and cannot be added.
// DiagnosticOnly. Do not drop Abstract; that would make the program compile.

UCLASS(Abstract)
class UCoverageUClassAbstractDefaultSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractDefaultComponentActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassAbstractDefaultSceneComponent AbstractComponent;
}
