/**
 * @version v1
 * @summary More than one RootComponent on an actor is rejected. An actor already has a root. Do not drop RootComponent from Root2.
 * @topic Feature
 */
/**
 * @version root
 * @summary More than one RootComponent on an actor is rejected. An actor already has a root. Do not drop RootComponent from Root2.
 * @topic Negative
 */
class ADefCompMultiRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root1;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root2;
}
/** @end */
