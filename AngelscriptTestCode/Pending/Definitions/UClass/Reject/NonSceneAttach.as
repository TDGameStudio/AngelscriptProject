/**
 * @version v1
 * @summary Attach on a non-scene actor component is rejected. Attach requires a scene component type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Attach on a non-scene actor component is rejected. Attach requires a scene component type.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPlainAttachLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassPlainAttachLogicComponent Logic;
}
/** @end */
