/**
 * @version v1
 * @summary A root plus an attached billboard DefaultComponent. C++ spawns the actor and checks that Billboard's attach parent is RootScene. The observer covers the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary A root plus an attached billboard DefaultComponent. C++ spawns the actor and checks that Billboard's attach parent is RootScene. The observer covers the local construct default.
 * @topic Baseline
 */
UCLASS()
class UTestDefaultComponentMultipleRoot : USceneComponent
{
}

UCLASS()
class UTestDefaultComponentMultipleBillboard : UBillboardComponent
{
}

UCLASS()
class ATestDefaultComponentMultiple : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentMultipleRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UTestDefaultComponentMultipleBillboard Billboard;

	/**
	 * Observe that a locally constructed actor has neither default component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.Multiple
	 * @Inputs an actor that has not been spawned
	 * @Return true when RootScene and Billboard are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		return Billboard == nullptr;
	}
}
/** @end */
