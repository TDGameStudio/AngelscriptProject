/**
 * Calling AddLambda on an event is rejected: lambda syntax is unsupported for
 * events. This file is the illegal program itself; do not add declarations that
 * would compile it away, since the missing overload is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EventLambdaSyntaxIsUnsupported
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.EventLambdaSyntaxIsUnsupported
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an AddLambda call on an event
 * @Return does not compile; diagnostic "No matching signatures to AddLambda"
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventLambdaSyntaxIsUnsupported CompileAndExpectFailure
 * @Provenance sha256=021aad4df95f65ee4984d1c3ff7f9d146675bde61d0b5f6f8a5ec60789e2dd96; lines 1273-1292.
 * @Provenance Expected diagnostic: No matching signatures to 'FCoverageEventLambdaSignal::AddLambda
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
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
