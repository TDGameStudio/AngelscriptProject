/**
 * @version v1
 * @summary DefaultComponent plus ShowOnActor on a plain UObject is rejected. The property type must derive from UActorComponent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent plus ShowOnActor on a plain UObject is rejected. The property type must derive from UActorComponent.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassShowOnActorPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassShowOnActorInstancedObjectActor : AActor
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UCoverageUClassShowOnActorPlainObject PlainObject;
}
/** @end */
