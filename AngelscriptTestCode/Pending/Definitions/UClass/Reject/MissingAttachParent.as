/**
 * @version v1
 * @summary Attach parent name that does not exist is rejected. The parent must name a DefaultComponent on the same actor.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Attach parent name that does not exist is rejected. The parent must name a DefaultComponent on the same actor.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassMissingAttachParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
/** @end */
