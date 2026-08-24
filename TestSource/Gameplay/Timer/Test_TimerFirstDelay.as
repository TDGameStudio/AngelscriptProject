// Theme: Gameplay.Timer. Isolated compile-fail: SetTimer first-delay overload is unbound.
// C++: AngelscriptCoverageTimerTests.cpp::TimerFirstDelay CompileAndExpectFailure.
// CSV WorldStory; C++ does not compile. Diagnostic: SetTimer.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerFirstDelayActor : AActor
{
	FTimerHandle FirstDelayHandle;

	UFUNCTION()
	void FirstDelayCallback()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FirstDelayHandle = System::SetTimer(this, n"FirstDelayCallback", 1.0f, true, 2.0f);
	}
}
