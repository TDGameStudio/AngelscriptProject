/**
 * @version v1
 * @summary AttachSocket without Attach is rejected. Socket names only apply to an attachment, so this DefaultComponent is illegal. Do not add Attach.
 * @topic Feature
 */
/**
 * @version root
 * @summary AttachSocket without Attach is rejected. Socket names only apply to an attachment, so this DefaultComponent is illegal. Do not add Attach.
 * @topic Negative
 */
class ADefCompSocketNoAttachActor : AActor
{
	UPROPERTY(DefaultComponent, AttachSocket = "Socket1")
	USceneComponent Child;
}
/** @end */
