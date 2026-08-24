// Theme: Gameplay.Timer. Isolated compile-fail: SystemLibrary::Delay is latent
// and requires FLatentActionInfo; a duration-only call does not resolve.
// C++: AngelscriptCoverageTimerTests.cpp::SystemDelay CompileAndExpectFailure.
// CSV WorldStory; C++ does not compile. Diagnostic: Delay.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerSystemDelayActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SystemLibrary::Delay(0.5f);
	}
}
