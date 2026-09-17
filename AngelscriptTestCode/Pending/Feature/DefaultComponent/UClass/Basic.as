/**
 * @version v1
 * @summary A scripted root DefaultComponent. C++ spawns the actor and checks that the actor root IsA UTestDefaultComponentBasicRoot. The observer covers the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary A scripted root DefaultComponent. C++ spawns the actor and checks that the actor root IsA UTestDefaultComponentBasicRoot. The observer covers the local construct default.
 * @topic Baseline
 */
UCLASS()
class UTestDefaultComponentBasicRoot : USceneComponent
{
}

UCLASS()
class ATestDefaultComponentBasic : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentBasicRoot RootScene;

	/**
	 * Observe that a locally constructed actor has no root scene component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.Basic
	 * @Inputs an actor that has not been spawned
	 * @Return true when RootScene is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return RootScene == nullptr;
	}
}
/** @end */
