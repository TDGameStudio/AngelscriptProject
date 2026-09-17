/**
 * @version v1
 * @summary An actor whose UAudioComponent BeginPlay exercises the playback and parameter controls. C++ verifies the four outcome flags. A null audio component is the early-out vector: only the validity flag is written and the rest.
 * @topic World
 */
/**
 * @version root
 * @summary An actor whose UAudioComponent BeginPlay exercises the playback and parameter controls. C++ verifies the four outcome flags. A null audio component is the early-out vector: only the validity flag is written and the rest.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay drives volume, pitch, UI sound, pause, play, stop and
	 * the three typed parameters, then records that playback stayed stopped.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentDeclarationAndControls
	 * @Inputs a default-attached UAudioComponent
	 * @Return all four flags true; with a null component only bAudioComponentValid is written
	 */
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
/** @end */
