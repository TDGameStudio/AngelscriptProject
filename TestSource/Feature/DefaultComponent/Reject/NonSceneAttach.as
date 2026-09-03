/**
 * Attach on a non-scene component is rejected. A DefaultComponent with Attach
 * must be a scene component; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NonSceneAttach
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.NonSceneAttach
 * @Kind CompileReject
 * @Covers DefaultComponent.NonSceneAttach
 * @Inputs UPROPERTY(DefaultComponent, Attach=Root) UCoverageUClassDefaultComponentLogicAttach Logic
 * @Return does not compile; "has a component attach set, but is not a type of scene component"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: Attach on a non-scene component.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_NonSceneAttach.
 * @Provenance Expected diagnostic: "has a component attach set, but is not a type of scene component".
 * @Provenance DiagnosticOnly. Do not change Logic to USceneComponent.
 */

UCLASS()
class UCoverageUClassDefaultComponentLogicAttach : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneAttach : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassDefaultComponentLogicAttach Logic;
}
