// Theme: World.Component. WorldStory: UAudioComponent fade and filter controls.
// C++: AngelscriptCoverageComponentTests.cpp::AudioComponentFadeAndFilterControls
// Oracle: ExpectBoolByPath bFadeControlsCallable and bFilterControlsCallable true.
// Extra: flags default false; null Audio leaves them false. FixtureIsolated.

UCLASS()
class ACoverageAudioFadeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bFadeControlsCallable = false;

	UPROPERTY()
	bool bFilterControlsCallable = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Audio == nullptr)
		{
			return;
		}

		Audio.FadeIn(0.01f, 0.5f, 0.0f);
		Audio.AdjustVolume(0.01f, 0.25f);
		Audio.FadeOut(0.01f, 0.0f);
		bFadeControlsCallable = true;

		Audio.SetLowPassFilterEnabled(true);
		Audio.SetLowPassFilterFrequency(1200.0f);
		Audio.SetHighPassFilterEnabled(true);
		Audio.SetHighPassFilterFrequency(300.0f);
		bFilterControlsCallable = true;
	}
}
