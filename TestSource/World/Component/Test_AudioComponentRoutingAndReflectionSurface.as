// Theme: World.Component. WorldStory: UAudioComponent Sound/Attenuation routing surface.
// C++: AngelscriptCoverageComponentTests.cpp::AudioComponentRoutingAndReflectionSurface
// Oracle: reflected Sound/Attenuation/Concurrency properties; bRoutingSurfaceCallable true
// after SetSound(nullptr)/SetAttenuationSettings(nullptr).
// Extra: bRoutingSurfaceCallable false until BeginPlay; nullptr is the empty routing vector.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ACoverageAudioRoutingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bRoutingSurfaceCallable = false;

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
