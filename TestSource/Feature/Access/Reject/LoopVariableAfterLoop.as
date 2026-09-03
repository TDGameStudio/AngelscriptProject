/**
 * Using a for-loop variable after the loop ends is rejected. This file is the
 * illegal program itself; do not declare I outside the loop, since the
 * out-of-scope read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.LoopVariableAfterLoop
 * @Harness CompileReject
 * @Tag Feature.Access.LoopVariableAfterLoop
 * @Kind CompileReject
 * @Covers Access.Scope
 * @Inputs a local read of I after the for-loop has closed
 * @Return does not compile; diagnostic "Access loop variable after loop"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: use a for-loop variable after the loop.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 2 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Access loop variable after loop".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * Attempt to read the loop counter after the loop ends.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
