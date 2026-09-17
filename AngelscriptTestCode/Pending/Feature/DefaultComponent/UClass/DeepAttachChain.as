/**
 * @version v1
 * @summary A RootScene -> MidScene -> LeafScene attach chain. C++ checks that MidScene and LeafScene properties exist on the generated class. The observers cover the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary A RootScene -> MidScene -> LeafScene attach chain. C++ checks that MidScene and LeafScene properties exist on the generated class. The observers cover the local construct default.
 * @topic Baseline
 */
UCLASS()
class ADeepAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent MidScene;

	UPROPERTY(DefaultComponent, Attach = MidScene)
	USceneComponent LeafScene;

	/**
	 * Observe that a locally constructed actor has no mid or leaf component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DeepAttachChain
	 * @Inputs an actor that has not been spawned
	 * @Return true when MidScene and LeafScene are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (MidScene != nullptr)
		{
			return false;
		}
		return LeafScene == nullptr;
	}
}
/** @end */
