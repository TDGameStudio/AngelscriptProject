/**
 * @version v1
 * @summary Two RootComponent default components on one actor are rejected. An actor may only name one root; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two RootComponent default components on one actor are rejected. An actor may only name one root; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassDefaultComponentDuplicateRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
/** @end */
