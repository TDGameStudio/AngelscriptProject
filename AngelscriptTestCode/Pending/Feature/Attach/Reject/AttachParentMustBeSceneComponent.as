/**
 * @version v1
 * @summary DefaultComponent Attach parent must be a scene component. Attaching a billboard to a plain actor component is rejected. This file is the illegal program itself; do not change PlainParent to a scene component.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent Attach parent must be a scene component. Attaching a billboard to a plain actor component is rejected. This file is the illegal program itself; do not change PlainParent to a scene component.
 * @topic Negative
 */
UCLASS()
class AComponentVerifyClassNonSceneParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent)
	UAngelscriptVerifyClassPlainActorComponent PlainParent;

	UPROPERTY(DefaultComponent, Attach = PlainParent)
	UBillboardComponent Billboard;
}
/** @end */
