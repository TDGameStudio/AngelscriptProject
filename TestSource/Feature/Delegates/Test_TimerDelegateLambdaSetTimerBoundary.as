// Theme: Feature.Delegates. Isolated compile-fail: FTimerDelegate lambda SetTimer is unsupported.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDelegateLambdaSetTimerBoundary
// CompileAndExpectFailure diagnostic contains "FTimerDelegate".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly. FixtureIsolated.

UCLASS()
class ACoverageTimerDelegateLambdaActor : AActor
{
	UPROPERTY()
	int LambdaCapturedValue = 0;

	FTimerHandle LambdaHandle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int CapturedValue = 42;
		LambdaHandle = System::SetTimer(FTimerDelegate(this, function()
		{
			LambdaCapturedValue = CapturedValue;
		}), 0.1f, false);
	}
}
