/**
 * BindLambda is not an AngelScript unicast API, so this program is rejected.
 * Script binds handlers with BindUFunction by object and function name.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.BindLambdaUnsupported
 * @Harness CompileReject
 * @Tag Feature.Delegates.BindLambdaUnsupported
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs OnSignal.BindLambda(this, n"Handler")
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateLambdaSyntaxIsUnsupported
 * @Provenance Expected diagnostic: No matching signatures to 'FLambdaUnsupportedSignal::BindLambda
 * @Provenance DiagnosticOnly. Isolation=none.
 */

/**
 * A void unicast used only to name BindLambda.
 *
 * @Kind CompileReject
 * @Covers Delegates.LambdaSyntax
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FLambdaUnsupportedSignal();

UCLASS()
class ACoverageDelegateLambdaUnsupportedActor : AActor
{
	FLambdaUnsupportedSignal OnSignal;

	/**
	 * A named handler that is not reachable through BindLambda.
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
	 * The isolated failing program: BindLambda is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; BindLambda has no matching signature
	 */
	void TryBindLambda()
	{
		OnSignal.BindLambda(this, n"Handler");
	}
}
