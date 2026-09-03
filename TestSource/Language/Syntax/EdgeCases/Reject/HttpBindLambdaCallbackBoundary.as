/**
 * Binding an HTTP request completion callback through BindLambda is rejected:
 * the HTTP callback surface is outside current AngelScript event coverage. This
 * file is the illegal program itself; do not declare HttpRequest, since the
 * undeclared name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.HttpBindLambdaCallbackBoundary
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.HttpBindLambdaCallbackBoundary
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a BindLambda call on an HTTP request delegate
 * @Return does not compile; diagnostic "HttpRequest"
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 3
 * @Provenance C++ CompileAndExpectFailure despite CSV WorldStory.
 * @Provenance sha256=75a3d0113a90c408bacb5b7aaa98fe6a949ae75f9e408934158c623c077ac715; lines 1467-1477.
 * @Provenance Expected diagnostic: HttpRequest
 * @Provenance HTTP BindLambda callback surface is outside current AS event coverage.
 * @Provenance Isolate this failing program; do not declare HttpRequest.
 * @Provenance DiagnosticOnly.
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
	void TryHttpRequestCallback()
	{
		HttpRequest.OnProcessRequestComplete.BindLambda(this, n"Handler");
	}
}
