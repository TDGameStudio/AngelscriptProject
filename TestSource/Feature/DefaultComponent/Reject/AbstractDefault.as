/**
 * DefaultComponent of an abstract class is rejected. An abstract component class
 * cannot be added as a default component; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.AbstractDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.AbstractDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.AbstractDefault
 * @Inputs UPROPERTY(DefaultComponent) UCoverageUClassDefaultComponentAbstractScene AbstractScene
 * @Return does not compile; "was marked as DefaultComponent, but the component class is abstract and cannot be added"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: DefaultComponent of an abstract class.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_AbstractDefault.
 * @Provenance Expected diagnostic: "was marked as DefaultComponent, but the component class is abstract and cannot be added".
 * @Provenance DiagnosticOnly. Do not drop Abstract from UCoverageUClassDefaultComponentAbstractScene.
 */

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
