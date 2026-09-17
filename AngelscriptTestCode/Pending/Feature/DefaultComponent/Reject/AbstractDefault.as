/**
 * @version v1
 * @summary DefaultComponent of an abstract class is rejected. An abstract component class cannot be added as a default component; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent of an abstract class is rejected. An abstract component class cannot be added as a default component; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS(Abstract)
class UCoverageUClassDefaultComponentAbstractScene : USceneComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentAbstractDefault : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentAbstractScene AbstractScene;
}
/** @end */
