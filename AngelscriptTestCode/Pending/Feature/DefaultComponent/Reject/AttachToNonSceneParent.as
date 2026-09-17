/**
 * @version v1
 * @summary Attach whose parent is not a SceneComponent is rejected. The named Attach parent must itself be a scene component; this file is the illegal program.
 * @topic Feature
 */
/**
 * @version root
 * @summary Attach whose parent is not a SceneComponent is rejected. The named Attach parent must itself be a scene component; this file is the illegal program.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassDefaultComponentAttachParentLogic : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentAttachToNonSceneParent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentAttachParentLogic Logic;

	UPROPERTY(DefaultComponent, Attach=Logic)
	USceneComponent Child;
}
/** @end */
