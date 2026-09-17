/**
 * @version v1
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents.
 * @topic Definitions
 */
/**
 * @version root
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassRootWithoutDefaultActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
/** @end */
