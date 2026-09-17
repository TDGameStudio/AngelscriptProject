/**
 * @version v1
 * @summary Passing a C++ lambda as a timer callback is rejected: the lambda syntax is not an AngelScript-facing API. This file is the illegal program itself; do not replace the lambda with a function name, since the lambda is the.
 * @topic Language
 */
/**
 * @version root
 * @summary Passing a C++ lambda as a timer callback is rejected: the lambda syntax is not an AngelScript-facing API. This file is the illegal program itself; do not replace the lambda with a function name, since the lambda is the.
 * @topic Negative
 */
UCLASS()
class ACoverageEventTimerLambdaBoundaryActor : AActor
{
	/**
	 * Attempt to pass a lambda to the timer API.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile
	 */
	UFUNCTION()
/** */
	void TryTimerLambda()
	{
		/**
		 * A statement passing a lambda literal to the timer API; the lambda has
		 * no expression value in AngelScript.
		 *
		 * @Covers Syntax.EdgeCases
		 * @Inputs a lambda literal as the callback argument
		 * @Return does not compile
		 */
		System::SetTimer(this, [](){}, 1.0f, false);
	}
}
/** @end */
