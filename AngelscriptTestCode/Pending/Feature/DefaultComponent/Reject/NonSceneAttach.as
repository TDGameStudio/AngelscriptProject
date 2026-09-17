/**
 * @version v1
 * @summary Attach on a non-scene component is rejected. A DefaultComponent with Attach must be a scene component; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach on a non-scene component is rejected. A DefaultComponent with Attach must be a scene component; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassDefaultComponentLogicAttach : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneAttach : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassDefaultComponentLogicAttach Logic;
}
/** @end */
