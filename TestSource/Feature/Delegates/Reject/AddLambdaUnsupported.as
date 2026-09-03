/**
 * AddLambda is not an AngelScript multicast API, so this program is rejected.
 * Script adds listeners with AddUFunction by object and function name.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.AddLambdaUnsupported
 * @Harness CompileReject
 * @Tag Feature.Delegates.AddLambdaUnsupported
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs OnSignal.AddLambda(this, n"Handler")
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: AddLambda is not an AS multicast API.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastLambdaSyntaxIsUnsupported
 * @Provenance CompileAndExpectFailure diagnostic contains "AddLambda".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly. FixtureIsolated.
 */

/**
 * A void multicast used only to name AddLambda.
 *
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FMulticastLambdaUnsupportedSignal();

UCLASS()
class ACoverageMulticastLambdaUnsupportedActor : AActor
{
	UPROPERTY()
	FMulticastLambdaUnsupportedSignal OnSignal;

	/**
	 * A named handler that is not reachable through AddLambda.
	 *
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Handler()
	{
	}

	/**
	 * The isolated failing program: AddLambda is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; AddLambda has no matching signature
	 */
	void TryAddLambda()
	{
		OnSignal.AddLambda(this, n"Handler");
	}
}
