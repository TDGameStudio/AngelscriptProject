/**
 * Attach whose parent is not a SceneComponent is rejected. The named Attach
 * parent must itself be a scene component; this file is the illegal program.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.AttachToNonSceneParent
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.AttachToNonSceneParent
 * @Kind CompileReject
 * @Covers DefaultComponent.AttachToNonSceneParent
 * @Inputs UPROPERTY(DefaultComponent, Attach=Logic) USceneComponent Child
 * @Return does not compile; "Attach parent Logic is not a SceneComponent for DefaultComponent Child"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: Attach parent is not a SceneComponent.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_AttachToNonSceneParent.
 * @Provenance Expected diagnostic: "Attach parent Logic is not a SceneComponent for DefaultComponent Child".
 * @Provenance DiagnosticOnly. Do not change Logic to USceneComponent.
 */

UCLASS()
class UCoverageUClassDefaultComponentAttachParentLogic : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentAttachToNonSceneParent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentAttachParentLogic Logic;

	UPROPERTY(DefaultComponent, Attach=Logic)
	USceneComponent Child;
}
