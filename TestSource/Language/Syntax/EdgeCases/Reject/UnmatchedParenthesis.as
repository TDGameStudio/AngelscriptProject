/**
 * An unmatched parenthesis inside an expression is rejected. This file is the
 * illegal program itself; do not close the parenthesis, since the missing
 * delimiter is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UnmatchedParenthesis
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.UnmatchedParenthesis
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an expression opened with a parenthesis that is never closed
 * @Return does not compile; diagnostic "unmatched parenthesis"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=8182105cb9380f58f9d0850cbb25f47431244b9680041ba410cce1f788dd365d; lines 292-294.
 * @Provenance Expected diagnostic: unmatched parenthesis in (1 + 2.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A function whose initializer opens a parenthesis it never closes.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = (1 + 2;
}
