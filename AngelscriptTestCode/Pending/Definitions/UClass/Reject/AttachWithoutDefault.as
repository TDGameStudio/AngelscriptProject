/**
 * @version v1
 * @summary Attach without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Attach without DefaultComponent is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassAttachWithoutDefaultActor : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
/** @end */
