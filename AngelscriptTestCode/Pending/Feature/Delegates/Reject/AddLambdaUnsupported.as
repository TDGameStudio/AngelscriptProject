/**
 * @version v1
 * @summary AddLambda is not an AngelScript multicast API, so this program is rejected. Script adds listeners with AddUFunction by object and function name.
 * @topic Feature
 */
/**
 * @version root
 * @summary AddLambda is not an AngelScript multicast API, so this program is rejected. Script adds listeners with AddUFunction by object and function name.
 * @topic Negative
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
/** @end */
