/**
 * RootComponent on a non-scene component is rejected. A RootComponent default
 * component must be a scene component; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NonSceneRoot
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.NonSceneRoot
 * @Kind CompileReject
 * @Covers DefaultComponent.NonSceneRoot
 * @Inputs UPROPERTY(DefaultComponent, RootComponent) UCoverageUClassDefaultComponentLogicRoot LogicRoot
 * @Return does not compile; "has RootComponent set, but is not a type of scene component"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: RootComponent on a non-scene component.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_NonSceneRoot.
 * @Provenance Expected diagnostic: "has RootComponent set, but is not a type of scene component".
 * @Provenance DiagnosticOnly. Do not change LogicRoot to USceneComponent.
 */

UCLASS()
class UCoverageUClassDefaultComponentLogicRoot : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassDefaultComponentLogicRoot LogicRoot;
}
