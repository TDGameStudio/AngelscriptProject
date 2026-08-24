// Theme: Feature.Delegates. Isolated compile-fail: single-shot FTimerDelegate lambda is unsupported.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDelegateLambdaSingleShotBoundary
// CompileAndExpectFailure diagnostic contains "FTimerDelegate".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly. FixtureIsolated.

UCLASS()
class ACoverageTimerDelegateLambdaActor : AActor
{
	UPROPERTY()
	int LambdaCallCount = 0;

	UPROPERTY()
	int LambdaObservedValue = 0;

	UPROPERTY()
	bool bLambdaHandleActiveAfterSet = false;

	UPROPERTY()
	int SeedValue = 41;

	FTimerHandle LambdaHandle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LambdaHandle = System::SetTimer(FTimerDelegate(this, function()
		{
			LambdaCallCount++;
			LambdaObservedValue = SeedValue + 1;
		}), 0.05f, false);

		bLambdaHandleActiveAfterSet = SystemLibrary::IsTimerActiveHandle(LambdaHandle);
	}
}
