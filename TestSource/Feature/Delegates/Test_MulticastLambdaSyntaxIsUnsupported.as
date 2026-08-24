// Theme: Feature.Delegates. Isolated compile-fail: AddLambda is not an AS multicast API.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastLambdaSyntaxIsUnsupported
// CompileAndExpectFailure diagnostic contains "AddLambda".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly. FixtureIsolated.

event void FMulticastLambdaUnsupportedSignal();

UCLASS()
class ACoverageMulticastLambdaUnsupportedActor : AActor
{
	UPROPERTY()
	FMulticastLambdaUnsupportedSignal OnSignal;

	UFUNCTION()
	void Handler()
	{
	}

	void TryAddLambda()
	{
		OnSignal.AddLambda(this, n"Handler");
	}
}
