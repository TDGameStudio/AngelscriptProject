/**
 * @version v1
 * @summary Attach to self is rejected. A DefaultComponent may not name itself as its Attach parent; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach to self is rejected. A DefaultComponent may not name itself as its Attach parent; this file is the illegal program itself.
 * @topic Negative
 */
class ADefCompSelfActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = Myself)
	USceneComponent Myself;
}
/** @end */
