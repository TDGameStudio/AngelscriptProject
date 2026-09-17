/**
 * @version v1
 * @summary Attach without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentAttachWithoutDefault : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
/** @end */
