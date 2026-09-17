/**
 * @version v1
 * @summary Calling AddLambda on an event is rejected: lambda syntax is unsupported for events. This file is the illegal program itself; do not add declarations that would compile it away, since the missing overload is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Calling AddLambda on an event is rejected: lambda syntax is unsupported for events. This file is the illegal program itself; do not add declarations that would compile it away, since the missing overload is the point.
 * @topic Negative
 */
/**
 * The event whose AddLambda call is the unsupported syntax under test.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
event void FCoverageEventLambdaSignal();

/**
 * An actor attempting to bind a handler through AddLambda.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
UCLASS()
class ACoverageEventLambdaUnsupportedActor : AActor
{
	UPROPERTY()
	FCoverageEventLambdaSignal OnSignal;

	/**
	 * A handler that would have received the lambda binding.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
/** */
	void Handler()
	{
	}

	/**
	 * Attempt to bind the handler through AddLambda.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile
	 */
	void TryLambda()
	{
		OnSignal.AddLambda(this, n"Handler");
	}
}
/** @end */
