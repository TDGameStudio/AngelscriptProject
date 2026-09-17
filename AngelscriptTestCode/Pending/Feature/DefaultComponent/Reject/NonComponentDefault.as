/**
 * @version v1
 * @summary DefaultComponent on a plain UObject is rejected. The property type must derive from UActorComponent; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent on a plain UObject is rejected. The property type must derive from UActorComponent; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassDefaultComponentPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonComponent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentPlainObject PlainObject;
}
/** @end */
