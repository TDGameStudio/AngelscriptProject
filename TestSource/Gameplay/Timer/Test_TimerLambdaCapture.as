// Theme: Gameplay.Timer. Isolated compile-fail: captured lambda FTimerDelegate
// is an unsupported System::SetTimer boundary.
// C++: AngelscriptCoverageTimerTests.cpp::TimerLambdaCapture CompileAndExpectFailure.
// CSV WorldStory; C++ does not compile. Diagnostic: FTimerDelegate.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerLambdaCaptureActor : AActor
{
	FTimerHandle LambdaHandle1;
	FTimerHandle LambdaHandle2;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerLambdaCapture: Testing lambda callbacks with captured variables");

		int LocalValue = 42;
		FString LocalMessage = "Hello from lambda";

		// Lambda timer with captured variables
		System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda timer callback executed");
			Print("Captured LocalValue: " + LocalValue);
			Print("Captured LocalMessage: " + LocalMessage);
		}), 0.1f, false);

		// Multiple lambda timers with different captured values
		int Value1 = 100;
		int Value2 = 200;

		LambdaHandle1 = System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda1 with captured value: " + Value1);
		}), 0.2f, false);

		LambdaHandle2 = System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda2 with captured value: " + Value2);
		}), 0.3f, false);
	}
}
