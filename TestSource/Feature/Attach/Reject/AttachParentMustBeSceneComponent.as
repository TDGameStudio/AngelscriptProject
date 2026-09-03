/**
 * DefaultComponent Attach parent must be a scene component. Attaching a
 * billboard to a plain actor component is rejected. This file is the illegal
 * program itself; do not change PlainParent to a scene component.
 *
 * @Theme Feature.Attach
 * @Subject Attach.AttachParentMustBeSceneComponent
 * @Harness CompileReject
 * @Tag Feature.Attach.AttachParentMustBeSceneComponent
 * @Kind CompileReject
 * @Covers Attach.AttachParentMustBeSceneComponent
 * @Inputs UPROPERTY(DefaultComponent, Attach = PlainParent) UBillboardComponent Billboard
 * @Return does not compile; diagnostic "DefaultComponent attach parent should reject non-scene components"
 * @Provenance Theme: Feature.Attach. NegativeDiagnostic: DefaultComponent Attach parent must be a scene component.
 * @Provenance C++: AngelscriptComponentMetadataValidationTests.cpp::AttachParentMustBeSceneComponent.
 * @Provenance Expected compile failure: "DefaultComponent attach parent should reject non-scene components"
 * @Provenance (ECompileResult::Error; generated actor is not published).
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

UCLASS()
class AComponentVerifyClassNonSceneParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent)
	UAngelscriptVerifyClassPlainActorComponent PlainParent;

	UPROPERTY(DefaultComponent, Attach = PlainParent)
	UBillboardComponent Billboard;
}
