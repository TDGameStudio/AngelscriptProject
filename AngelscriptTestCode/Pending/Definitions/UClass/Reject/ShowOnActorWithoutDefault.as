/**
 * @version v1
 * @summary ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be used on default components in actors.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be used on default components in actors.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassShowOnActorWithoutDefaultActor : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
/** @end */
