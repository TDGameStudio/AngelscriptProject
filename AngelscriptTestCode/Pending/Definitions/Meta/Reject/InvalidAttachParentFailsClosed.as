/**
 * @version v1
 * @summary A DefaultComponent Attach parent must exist, so attaching Billboard to the missing MissingParent name is rejected. Isolate this failing program; do not add MissingParent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A DefaultComponent Attach parent must exist, so attaching Billboard to the missing MissingParent name is rejected. Isolate this failing program; do not add MissingParent.
 * @topic Negative
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
/** @end */
