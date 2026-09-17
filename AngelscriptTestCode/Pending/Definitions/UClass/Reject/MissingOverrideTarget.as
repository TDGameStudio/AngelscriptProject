/**
 * @version v1
 * @summary OverrideComponent target missing on the base is rejected. The override name must match a component on the base class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent target missing on the base is rejected. The override name must match a component on the base class.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassMissingOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassMissingOverrideChildActor : ACoverageUClassMissingOverrideBaseActor
{
	UPROPERTY(OverrideComponent=MissingScene)
	USceneComponent Replacement;
}
/** @end */
