/**
 * @version v1
 * @summary Attach to a parent that does not exist is rejected. The named Attach parent must be a declared DefaultComponent; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach to a parent that does not exist is rejected. The named Attach parent must be a declared DefaultComponent; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentMissingAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
/** @end */
