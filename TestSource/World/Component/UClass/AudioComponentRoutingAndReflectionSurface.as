/**
 * An actor whose UAudioComponent BeginPlay clears the sound and attenuation
 * routing. C++ verifies the flag and reads the reflected Sound / Attenuation /
 * Concurrency properties. A null audio component leaves the flag false.
 *
 * @Theme World.Component
 * @Subject Component.AudioComponentRoutingAndReflectionSurface
 * @Harness UClass
 * @Tag World.Component.AudioComponentRoutingAndReflectionSurface
 * @Provenance Theme: World.Component. WorldStory: UAudioComponent Sound/Attenuation routing surface.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::AudioComponentRoutingAndReflectionSurface
 * @Provenance Oracle: reflected Sound/Attenuation/Concurrency properties; bRoutingSurfaceCallable true
 * @Provenance after SetSound(nullptr)/SetAttenuationSettings(nullptr).
 * @Provenance Extra: bRoutingSurfaceCallable false until BeginPlay; nullptr is the empty routing vector.
 * @Provenance Do not spawn from script. FixtureIsolated.
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
