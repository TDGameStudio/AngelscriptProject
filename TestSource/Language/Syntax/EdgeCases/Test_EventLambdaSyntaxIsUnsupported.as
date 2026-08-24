// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic compile-fail.
// C++: AngelscriptCoverageEventTests.cpp::EventLambdaSyntaxIsUnsupported CompileAndExpectFailure
// sha256=021aad4df95f65ee4984d1c3ff7f9d146675bde61d0b5f6f8a5ec60789e2dd96; lines 1273-1292.
// Expected diagnostic: No matching signatures to 'FCoverageEventLambdaSignal::AddLambda
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

event void FCoverageEventLambdaSignal();

UCLASS()
class ACoverageEventLambdaUnsupportedActor : AActor
{
	UPROPERTY()
	FCoverageEventLambdaSignal OnSignal;

	UFUNCTION()
	void Handler()
	{
	}

	void TryLambda()
	{
		OnSignal.AddLambda(this, n"Handler");
	}
}
