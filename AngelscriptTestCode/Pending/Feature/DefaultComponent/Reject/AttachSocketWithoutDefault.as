/**
 * @version v1
 * @summary AttachSocket without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary AttachSocket without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentAttachSocketWithoutDefault : AActor
{
	UPROPERTY(AttachSocket="LooseSocket")
	USceneComponent Child;
}
/** @end */
