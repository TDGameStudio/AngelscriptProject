/**
 * @version v1
 * @summary DefaultComponent on a plain UObject is rejected. The property type must derive from UActorComponent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent on a plain UObject is rejected. The property type must derive from UActorComponent.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPlainDefaultObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentDefaultActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassPlainDefaultObject PlainObject;
}
/** @end */
