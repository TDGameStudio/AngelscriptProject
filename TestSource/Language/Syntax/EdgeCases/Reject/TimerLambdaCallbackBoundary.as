/**
 * Passing a C++ lambda as a timer callback is rejected: the lambda syntax is not
 * an AngelScript-facing API. This file is the illegal program itself; do not
 * replace the lambda with a function name, since the lambda is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.TimerLambdaCallbackBoundary
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.TimerLambdaCallbackBoundary
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a lambda passed to System::SetTimer
 * @Return does not compile; diagnostic "Expected expression value"
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 2
 * @Provenance C++ CompileAndExpectFailure despite CSV WorldStory.
 * @Provenance sha256=1c985f6358593f0b650f16fa15face9933819e0ef07d1848e5e228329baa7515; lines 1444-1454.
 * @Provenance Expected diagnostic: Expected expression value
 * @Provenance C++ lambda timer callback syntax is not an AS-facing API. Isolate this failing program.
 * @Provenance DiagnosticOnly.
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