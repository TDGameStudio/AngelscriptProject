/**
 * @version v1
 * @summary Arrow, audio and input components declared as default components. C++ reads the validity flags by path. All flags stay false until BeginPlay runs.
 * @topic World
 */
/**
 * @version root
 * @summary Arrow, audio and input components declared as default components. C++ reads the validity flags by path. All flags stay false until BeginPlay runs.
 * @topic Baseline
 */
UCLASS()
class ACoverageComponentSpecialTypeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY(DefaultComponent)
	UInputComponent Input;

	UPROPERTY()
	bool ArrowValid = false;

	UPROPERTY()
	bool AudioValid = false;

	UPROPERTY()
	bool InputValid = false;

	UPROPERTY()
	bool SceneTypesAttached = false;

	/**
	 * WorldStory: BeginPlay records which default components resolved and whether
	 * both scene types ended up attached to the root.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpecialTypeDeclarations
	 * @Inputs four default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrowValid = Arrow != nullptr;
		AudioValid = Audio != nullptr;
		InputValid = Input != nullptr;
		SceneTypesAttached = ArrowValid && AudioValid && Arrow.IsAttachedTo(Root) && Audio.IsAttachedTo(Root);
	}
}
/** @end */
