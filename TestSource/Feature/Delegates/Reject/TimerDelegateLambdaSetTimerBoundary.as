/**
 * Constructing an FTimerDelegate from an inline lambda and passing it to
 * SetTimer is rejected. Script timers bind by object and function name.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.TimerDelegateLambdaSetTimerBoundary
 * @Harness CompileReject
 * @Tag Feature.Delegates.TimerDelegateLambdaSetTimerBoundary
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs System::SetTimer(FTimerDelegate(this, function() { ... }), 0.1f, false)
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: FTimerDelegate lambda SetTimer is unsupported.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDelegateLambdaSetTimerBoundary
 * @Provenance CompileAndExpectFailure diagnostic contains "FTimerDelegate".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly. FixtureIsolated.
 */

UCLASS()
class ACoverageTimerDelegateLambdaActor : AActor
{
	UPROPERTY()
	int LambdaCapturedValue = 0;

	FTimerHandle LambdaHandle;

	/**
	 * The isolated failing program: a lambda FTimerDelegate passed to SetTimer.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; FTimerDelegate has no lambda constructor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int CapturedValue = 42;
		/**
		 * Illegal lambda passed to FTimerDelegate.
		 *
		 * @Kind CompileReject
		 * @Covers Delegates.LambdaSyntax
		 * @Inputs none
		 * @Return does not compile
		 */
		LambdaHandle = System::SetTimer(FTimerDelegate(this, function()
		{
			LambdaCapturedValue = CapturedValue;
		}), 0.1f, false);
	}
}
