// Theme: Feature.DefaultComponent. Isolated compile-fail: DefaultComponent of an abstract class.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "was marked as DefaultComponent, but the component class is abstract and cannot be added".
// DiagnosticOnly. Do not drop Abstract from UCoverageUClassDefaultComponentAbstractScene.

UCLASS(Abstract)
class UCoverageUClassDefaultComponentAbstractScene : USceneComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentAbstractDefault : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentAbstractScene AbstractScene;
}
