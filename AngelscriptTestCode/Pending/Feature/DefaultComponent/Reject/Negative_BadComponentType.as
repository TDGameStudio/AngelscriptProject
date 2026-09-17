/**
 * @version v1
 * @summary DefaultComponent on a non-UActorComponent type is rejected. The property type must be a component; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent on a non-UActorComponent type is rejected. The property type must be a component; this file is the illegal program itself.
 * @topic Negative
 */
class ADefCompBadTypeActor : AActor
{
	UPROPERTY(DefaultComponent)
	AActor SubActor;
}
/** @end */
