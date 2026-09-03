/**
 * Calling AddDynamic on a script event is rejected: it is a non-script-facing
 * API. This file is the illegal program itself; do not add declarations that
 * would compile it away, since the missing overload is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EventAddDynamicBoundary
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.EventAddDynamicBoundary
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an AddDynamic call on a script event
 * @Return does not compile; diagnostic "No matching signatures to AddDynamic"
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 1
 * @Provenance C++ CompileAndExpectFailure despite CSV WorldStory.
 * @Provenance sha256=73589d9425943f8e7f6989596790fa0392ade226941fcb0a92f8ba3573986ae1; lines 1411-1431.
 * @Provenance Expected diagnostic: No matching signatures to 'FCoverageBoundaryEvent::AddDynamic
 * @Provenance Isolate this failing program. DiagnosticOnly.
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
	void TryAddDynamic()
	{
		OnBoundary.AddDynamic(this, n"Handler");
	}
}
