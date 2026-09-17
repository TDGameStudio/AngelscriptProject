/**
 * @version v1
 * @summary OverrideComponent also marked RootComponent is rejected. RootComponent can only be specified on DefaultComponents.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent also marked RootComponent is rejected. RootComponent can only be specified on DefaultComponents.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassOverrideWithRootBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassOverrideWithRootChildActor : ACoverageUClassOverrideWithRootBaseActor
{
	UPROPERTY(OverrideComponent=Root, RootComponent)
	USceneComponent Replacement;
}
/** @end */
