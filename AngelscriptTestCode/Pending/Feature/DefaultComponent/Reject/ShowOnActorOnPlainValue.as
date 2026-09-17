/**
 * @version v1
 * @summary ShowOnActor on a non-component property is rejected. ShowOnActor can only be used on default components in actors; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary ShowOnActor on a non-component property is rejected. ShowOnActor can only be used on default components in actors; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class AShowOnActorInvalidCarrier : AActor
{
	UPROPERTY(ShowOnActor)
	int PlainValue;
}
/** @end */
