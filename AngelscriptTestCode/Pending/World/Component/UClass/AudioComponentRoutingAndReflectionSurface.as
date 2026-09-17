/**
 * @version v1
 * @summary An actor whose UAudioComponent BeginPlay clears the sound and attenuation routing. C++ verifies the flag and reads the reflected Sound / Attenuation / Concurrency properties. A null audio component leaves the flag false.
 * @topic World
 */
/**
 * @version root
 * @summary An actor whose UAudioComponent BeginPlay clears the sound and attenuation routing. C++ verifies the flag and reads the reflected Sound / Attenuation / Concurrency properties. A null audio component leaves the flag false.
 * @topic Baseline
 */
UCLASS()
class ACoverageAudioRoutingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bRoutingSurfaceCallable = false;

	/**
	 * WorldStory: BeginPlay clears both routing slots to nullptr.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentRoutingAndReflectionSurface
	 * @Inputs a default-attached UAudioComponent
	 * @Return bRoutingSurfaceCallable true; with a null component it stays false
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Audio == nullptr)
		{
			return;
		}

		Audio.SetSound(nullptr);
		Audio.SetAttenuationSettings(nullptr);
		bRoutingSurfaceCallable = true;
	}
}
/** @end */
