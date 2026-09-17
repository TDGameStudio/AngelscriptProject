/**
 * @version v1
 * @summary DefaultComponent that uses an Abstract scene class is rejected. Abstract component classes cannot be added as default components.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent that uses an Abstract scene class is rejected. Abstract component classes cannot be added as default components.
 * @topic Negative
 */
UCLASS(Abstract)
class UCoverageUClassAbstractDefaultSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractDefaultComponentActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassAbstractDefaultSceneComponent AbstractComponent;
}
/** @end */
