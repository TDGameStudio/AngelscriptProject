// Theme: Gameplay.Timer. Isolated compile-fail: SetTimer by function name
// rejects callbacks that require parameters.
// C++: AngelscriptCoverageTimerTests.cpp::TimerWithParameters CompileAndExpectFailure.
// CSV WorldStory; C++ does not compile. Diagnostic: SetTimer.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerWithParametersActor : AActor
{
	FTimerHandle ParameterHandle;

	UFUNCTION()
	void ParameterCallback(int Value, FString Message)
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParameterHandle = System::SetTimer(this, n"ParameterCallback", 0.1f, false, 42, "payload");
	}
}
