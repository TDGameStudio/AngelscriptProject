/**
 * @version v1
 * @summary RootComponent on a non-scene actor component is rejected. RootComponent requires a scene component type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary RootComponent on a non-scene actor component is rejected. RootComponent requires a scene component type.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPlainRootLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassPlainRootLogicComponent RootLogic;
}
/** @end */
