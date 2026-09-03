/**
 * Arrow, audio and input components declared as default components. C++ reads the
 * validity flags by path. All flags stay false until BeginPlay runs.
 *
 * @Theme World.Component
 * @Subject Component.SpecialTypeDeclarations
 * @Harness UClass
 * @Tag World.Component.ComponentSpecialTypeDeclarations
 * @Provenance Theme: World.Component. WorldStory: Arrow/Audio/Input default components.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentSpecialTypeDeclarations
 * @Provenance Oracle: ExpectBoolByPath ArrowValid, AudioValid true; InputValid and SceneTypesAttached set in BeginPlay.
 * @Provenance Extra: all flags default false until BeginPlay. Do not spawn from script. FixtureIsolated.
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
