/**
 * @version v1
 * @summary Calling AddDynamic on a script event is rejected: it is a non-script-facing API. This file is the illegal program itself; do not add declarations that would compile it away, since the missing overload is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Calling AddDynamic on a script event is rejected: it is a non-script-facing API. This file is the illegal program itself; do not add declarations that would compile it away, since the missing overload is the point.
 * @topic Negative
 */
/**
 * The event whose AddDynamic call is the unsupported API under test.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
event void FCoverageBoundaryEvent();

UCLASS()
class ACoverageEventAddDynamicBoundaryActor : AActor
{
	UPROPERTY()
	FCoverageBoundaryEvent OnBoundary;

	/**
	 * A handler that would have received the dynamic binding.
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
	 * Attempt to bind the handler through AddDynamic.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile
	 */
	UFUNCTION()
/** */
	void TryAddDynamic()
	{
		OnBoundary.AddDynamic(this, n"Handler");
	}
}
/** @end */
