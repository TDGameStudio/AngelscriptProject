/**
 * @version v1
 * @summary DefaultComponent on a non-component type is rejected. The property type must be a component, not a primitive; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent on a non-component type is rejected. The property type must be a component, not a primitive; this file is the illegal program itself.
 * @topic Negative
 */
class ADefCompNonCompActor : AActor
{
	UPROPERTY(DefaultComponent)
	int X;
}
/** @end */
