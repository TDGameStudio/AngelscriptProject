/**
 * @version v1
 * @summary OverrideComponent also marked Attach is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent also marked Attach is rejected. Attachments can only be specified on DefaultComponents.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassOverrideWithAttachBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;
}

UCLASS()
class ACoverageUClassOverrideWithAttachChildActor : ACoverageUClassOverrideWithAttachBaseActor
{
	UPROPERTY(OverrideComponent=Child, Attach=Root)
	USceneComponent Replacement;
}
/** @end */
