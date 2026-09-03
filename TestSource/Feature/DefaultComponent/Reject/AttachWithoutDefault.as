/**
 * Attach without DefaultComponent is rejected. Attachments can only be specified
 * on DefaultComponents; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.AttachWithoutDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.AttachWithoutDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.AttachWithoutDefault
 * @Inputs UPROPERTY(Attach=Root) USceneComponent Child
 * @Return does not compile; "Attachments can only be specified on DefaultComponents"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: Attach without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_AttachWithoutDefault.
 * @Provenance Expected diagnostic: "Attachments can only be specified on DefaultComponents".
 * @Provenance DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassDefaultComponentAttachWithoutDefault : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
