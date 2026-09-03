/**
 * AttachSocket without DefaultComponent is rejected. Attachments can only be
 * specified on DefaultComponents; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.AttachSocketWithoutDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.AttachSocketWithoutDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.AttachSocketWithoutDefault
 * @Inputs UPROPERTY(AttachSocket="LooseSocket") USceneComponent Child
 * @Return does not compile; "Attachments can only be specified on DefaultComponents"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: AttachSocket without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_AttachSocketWithoutDefault.
 * @Provenance Expected diagnostic: "Attachments can only be specified on DefaultComponents".
 * @Provenance DiagnosticOnly. Do not add DefaultComponent.
 */

UCLASS()
class ACoverageUClassDefaultComponentAttachSocketWithoutDefault : AActor
{
	UPROPERTY(AttachSocket="LooseSocket")
	USceneComponent Child;
}
