/**
 * A single-shot FTimerDelegate built from an inline lambda is rejected.
 * Script timers bind by object and function name, not a lambda constructor.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.TimerDelegateLambdaSingleShotBoundary
 * @Harness CompileReject
 * @Tag Feature.Delegates.TimerDelegateLambdaSingleShotBoundary
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs System::SetTimer(FTimerDelegate(this, function() { ... }), 0.05f, false)
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: single-shot FTimerDelegate lambda is unsupported.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDelegateLambdaSingleShotBoundary
 * @Provenance CompileAndExpectFailure diagnostic contains "FTimerDelegate".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly. FixtureIsolated.
 */

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

	/**
	 * The isolated failing program: a single-shot lambda FTimerDelegate.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; FTimerDelegate has no lambda constructor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
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
			LambdaCallCount++;
			LambdaObservedValue = SeedValue + 1;
		}), 0.05f, false);

		bLambdaHandleActiveAfterSet = SystemLibrary::IsTimerActiveHandle(LambdaHandle);
	}
}
