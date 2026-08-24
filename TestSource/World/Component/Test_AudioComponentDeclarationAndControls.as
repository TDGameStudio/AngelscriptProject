// Theme: World.Component. WorldStory: UAudioComponent playback and parameter controls.
// C++: AngelscriptCoverageComponentTests.cpp::AudioComponentDeclarationAndControls
// Oracle: bAudioComponentValid, bPlaybackControlsCallable, bParameterControlsCallable,
// bAudioRemainsStoppedWithoutSound all true after BeginPlay.
// Extra: flags default false; null Audio returns without setting them. FixtureIsolated.

UCLASS()
class ACoverageAudioComponentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bAudioComponentValid = false;

	UPROPERTY()
	bool bPlaybackControlsCallable = false;

	UPROPERTY()
	bool bParameterControlsCallable = false;

	UPROPERTY()
	bool bAudioRemainsStoppedWithoutSound = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bAudioComponentValid = Audio != nullptr;
		if (Audio == nullptr)
		{
			return;
		}

		Audio.SetVolumeMultiplier(0.25f);
		Audio.SetPitchMultiplier(1.50f);
		Audio.SetUISound(true);
		Audio.SetPaused(true);
		Audio.SetPaused(false);
		Audio.Play(0.0f);
		Audio.Stop();
		bPlaybackControlsCallable = true;

		Audio.SetBoolParameter(n"CoverageBool", true);
		Audio.SetFloatParameter(n"CoverageFloat", 0.75f);
		Audio.SetIntParameter(n"CoverageInt", 12);
		bParameterControlsCallable = true;

		bAudioRemainsStoppedWithoutSound = !Audio.IsPlaying();
	}
}
