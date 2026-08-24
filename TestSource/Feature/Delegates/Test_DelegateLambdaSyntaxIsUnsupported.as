// Theme: Feature.Delegates. Isolated compile-fail.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateLambdaSyntaxIsUnsupported
// Expected diagnostic: No matching signatures to 'FLambdaUnsupportedSignal::BindLambda
// DiagnosticOnly. Isolation=none.

delegate void FLambdaUnsupportedSignal();

UCLASS()
class ACoverageDelegateLambdaUnsupportedActor : AActor
{
	FLambdaUnsupportedSignal OnSignal;

	UFUNCTION()
	void Handler()
	{
	}

	void TryBindLambda()
	{
		OnSignal.BindLambda(this, n"Handler");
	}
}
