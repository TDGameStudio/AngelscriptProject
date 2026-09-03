/**
 * Using a block-local variable after the block ends is rejected. This file is
 * the illegal program itself; do not declare X outside the block, since the
 * out-of-scope read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.VariableAfterBlockEnds
 * @Harness CompileReject
 * @Tag Feature.Access.VariableAfterBlockEnds
 * @Kind CompileReject
 * @Covers Access.Scope
 * @Inputs a local read after the declaring block has closed
 * @Return does not compile; diagnostic "Access variable after block ends"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: use a block-local variable after the block ends.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 1 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Access variable after block ends".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * Attempt to read a block-local after the block ends.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	{
		int X = 1;
	}
	int Y = X;
}
