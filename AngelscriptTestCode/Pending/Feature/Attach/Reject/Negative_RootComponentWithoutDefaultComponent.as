/**
 * @version v1
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents. Do not add DefaultComponent.
 * @topic Feature
 */
/**
 * @version root
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents. Do not add DefaultComponent.
 * @topic Negative
 */
class ADefCompRootOnlyActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
/** @end */
