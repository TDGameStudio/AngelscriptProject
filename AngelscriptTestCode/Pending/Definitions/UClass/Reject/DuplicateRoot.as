/**
 * @version v1
 * @summary Two RootComponent default components are rejected. An actor already has root component Root.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Two RootComponent default components are rejected. An actor already has root component Root.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDuplicateRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
/** @end */
