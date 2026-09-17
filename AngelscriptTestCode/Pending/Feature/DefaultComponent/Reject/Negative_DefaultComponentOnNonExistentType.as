/**
 * @version v1
 * @summary DefaultComponent of a type that does not exist is rejected. The property type must name a real component class; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent of a type that does not exist is rejected. The property type must name a real component class; this file is the illegal program itself.
 * @topic Negative
 */
class ADefCompBadTypeNameActor : AActor
{
	UPROPERTY(DefaultComponent)
	UNonExistentComponent Comp;
}
/** @end */
