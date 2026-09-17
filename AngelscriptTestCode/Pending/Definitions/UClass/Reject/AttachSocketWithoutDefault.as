/**
 * @version v1
 * @summary AttachSocket without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AttachSocket without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassAttachSocketWithoutDefaultActor : AActor
{
	UPROPERTY(AttachSocket="LooseSocket")
	USceneComponent Child;
}
/** @end */
