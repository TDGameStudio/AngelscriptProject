// Theme: World.Component. WorldStory: Arrow/Audio/Input default components.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentSpecialTypeDeclarations
// Oracle: ExpectBoolByPath ArrowValid, AudioValid true; InputValid and SceneTypesAttached set in BeginPlay.
// Extra: all flags default false until BeginPlay. Do not spawn from script. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrowValid = Arrow != nullptr;
		AudioValid = Audio != nullptr;
		InputValid = Input != nullptr;
		SceneTypesAttached = ArrowValid && AudioValid && Arrow.IsAttachedTo(Root) && Audio.IsAttachedTo(Root);
	}
}
