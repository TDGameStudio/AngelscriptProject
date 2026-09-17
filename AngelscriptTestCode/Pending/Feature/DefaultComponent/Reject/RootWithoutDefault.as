/**
 * @version v1
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary RootComponent without DefaultComponent is rejected. RootComponent can only be specified on DefaultComponents; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentRootWithoutDefault : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
/** @end */
