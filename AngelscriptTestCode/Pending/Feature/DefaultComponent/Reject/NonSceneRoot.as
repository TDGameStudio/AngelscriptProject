/**
 * @version v1
 * @summary RootComponent on a non-scene component is rejected. A RootComponent default component must be a scene component; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary RootComponent on a non-scene component is rejected. A RootComponent default component must be a scene component; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassDefaultComponentLogicRoot : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonSceneRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassDefaultComponentLogicRoot LogicRoot;
}
/** @end */
