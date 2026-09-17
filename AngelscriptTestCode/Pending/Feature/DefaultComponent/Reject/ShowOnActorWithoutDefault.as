/**
 * @version v1
 * @summary ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be used on default components in actors; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be used on default components in actors; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentShowOnActorWithoutDefault : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
/** @end */
