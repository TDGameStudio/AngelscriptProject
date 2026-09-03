/**
 * Attach to a parent that does not exist is rejected. The named Attach parent
 * must be a declared DefaultComponent; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.MissingAttachParent
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.MissingAttachParent
 * @Kind CompileReject
 * @Covers DefaultComponent.MissingAttachParent
 * @Inputs UPROPERTY(DefaultComponent, Attach=MissingParent) USceneComponent Child
 * @Return does not compile; "Attach parent MissingParent does not exist for DefaultComponent Child"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: Attach parent does not exist.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_MissingAttachParent.
 * @Provenance Expected diagnostic: "Attach parent MissingParent does not exist for DefaultComponent Child".
 * @Provenance DiagnosticOnly. Do not declare MissingParent.
 */

UCLASS()
class ACoverageUClassDefaultComponentMissingAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
