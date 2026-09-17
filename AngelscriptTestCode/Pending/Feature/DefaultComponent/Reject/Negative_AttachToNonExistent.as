/**
 * @version v1
 * @summary Attach to a component that does not exist is rejected. The named Attach target must be a declared default component; this file is the illegal program.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach to a component that does not exist is rejected. The named Attach target must be a declared default component; this file is the illegal program.
 * @topic Negative
 */
class ADefCompBadAttachActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = NonExistent)
	USceneComponent Child;
}
/** @end */
