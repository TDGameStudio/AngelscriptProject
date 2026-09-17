/**
 * @version v1
 * @summary Binding an HTTP request completion callback through BindLambda is rejected: the HTTP callback surface is outside current AngelScript event coverage. This file is the illegal program itself; do not declare HttpRequest.
 * @topic Language
 */
/**
 * @version root
 * @summary Binding an HTTP request completion callback through BindLambda is rejected: the HTTP callback surface is outside current AngelScript event coverage. This file is the illegal program itself; do not declare HttpRequest.
 * @topic Negative
 */
UCLASS()
class ACoverageEventHttpBoundaryActor : AActor
{
	/**
	 * Attempt to bind an HTTP completion callback through BindLambda.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile
	 */
	UFUNCTION()
/** */
	void TryHttpRequestCallback()
	{
		HttpRequest.OnProcessRequestComplete.BindLambda(this, n"Handler");
	}
}
/** @end */
