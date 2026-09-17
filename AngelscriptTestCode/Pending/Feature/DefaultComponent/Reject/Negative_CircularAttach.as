/**
 * @version v1
 * @summary Circular attachment is rejected. Two DefaultComponents may not Attach to each other; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Circular attachment is rejected. Two DefaultComponents may not Attach to each other; this file is the illegal program itself.
 * @topic Negative
 */
class ADefCompCircularActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = CompB)
	USceneComponent CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	USceneComponent CompB;
}
/** @end */
