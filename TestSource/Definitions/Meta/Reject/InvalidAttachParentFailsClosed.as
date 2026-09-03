/**
 * A DefaultComponent Attach parent must exist, so attaching Billboard to the
 * missing MissingParent name is rejected. Isolate this failing program; do not
 * add MissingParent.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.InvalidAttachParentFailsClosed
 * @Harness CompileReject
 * @Tag Definitions.Meta.InvalidAttachParentFailsClosed
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: DefaultComponent Attach parent must exist.
 * @Provenance C++: InvalidAttachParentFailsClosed; bCompiled false, ECompileResult::Error.
 * @Provenance Expected diagnostic: invalid attach parent MissingParent.
 * @Provenance Isolate this failing program; do not add MissingParent.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UComponentInvalidAttachParentRoot : USceneComponent
{
}

/**
 * The isolated failing program: Billboard attaches to MissingParent, which is not declared.
 *
 * @Kind CompileReject
 * @Covers Meta.InvalidAttachParentFailsClosed
 * @Inputs Attach = MissingParent
 * @Return does not compile; invalid attach parent MissingParent
 */
UCLASS()
class AComponentInvalidAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UComponentInvalidAttachParentRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = MissingParent)
	UBillboardComponent Billboard;
}
