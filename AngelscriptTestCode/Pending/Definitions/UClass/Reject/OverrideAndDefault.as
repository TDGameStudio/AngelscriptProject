/**
 * @version v1
 * @summary DefaultComponent combined with OverrideComponent is rejected. The two specifiers must not be used on the same property.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent combined with OverrideComponent is rejected. The two specifiers must not be used on the same property.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassOverrideAndDefaultActor : AActor
{
	UPROPERTY(DefaultComponent, OverrideComponent=Root)
	USceneComponent Root;
}
/** @end */
