/**
 * An actor whose UAudioComponent BeginPlay exercises the fade and filter
 * controls. C++ verifies both outcome flags by path. A null audio component is
 * the early-out vector that leaves both flags false.
 *
 * @Theme World.Component
 * @Subject Component.AudioComponentFadeAndFilterControls
 * @Harness UClass
 * @Tag World.Component.AudioComponentFadeAndFilterControls
 * @Provenance Theme: World.Component. WorldStory: UAudioComponent fade and filter controls.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::AudioComponentFadeAndFilterControls
 * @Provenance Oracle: ExpectBoolByPath bFadeControlsCallable and bFilterControlsCallable true.
 * @Provenance Extra: flags default false; null Audio leaves them false. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay fades in, adjusts volume and fades out, then enables
	 * both the low pass and the high pass filter.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentFadeAndFilterControls
	 * @Inputs a default-attached UAudioComponent
	 * @Return both flags true; with a null component both stay false
	 */
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
