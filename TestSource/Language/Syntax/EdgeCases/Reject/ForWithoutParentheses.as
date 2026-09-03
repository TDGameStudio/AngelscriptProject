/**
 * A for statement without parentheses around its header is rejected. This file is
 * the illegal program itself; do not add the parentheses, since their absence is
 * the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForWithoutParentheses
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ForWithoutParentheses
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a for statement with no parentheses
 * @Return does not compile; diagnostic "For without parentheses"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NoParen
 * @Provenance sha256=093c2bc494cafeff1cd0201c32926d5ef9feea5c9a57c012f42161de0e466c57; lines 184-186.
 * @Provenance Expected diagnostic: "For without parentheses".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A loop whose header is not enclosed in parentheses.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for int I = 0; I < 10; ++I
	{
	}
}
