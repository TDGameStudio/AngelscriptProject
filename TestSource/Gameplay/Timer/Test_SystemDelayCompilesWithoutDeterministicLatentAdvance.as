// Theme: Gameplay.Timer. Isolated compile-fail: SystemLibrary::Delay latent overload
// requires FLatentActionInfo and cannot complete synchronously.
// C++: AngelscriptCoverageTimerTests.cpp::SystemDelayCompilesWithoutDeterministicLatentAdvance
// CompileAndExpectFailure. CSV WorldStory; C++ does not compile. Diagnostic: Delay.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerSystemDelayBoundaryActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SystemLibrary::Delay(0.25f);
	}
}
