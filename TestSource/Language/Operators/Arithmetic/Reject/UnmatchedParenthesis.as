/**
 * A parenthesised expression that opens a bracket and never closes it is
 * rejected. This file is the illegal program itself; do not add the closing
 * parenthesis, since the unmatched bracket is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.UnmatchedParenthesis
 * @Harness CompileReject
 * @Tag Language.Operators.UnmatchedParenthesis
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs (1 + 2; with no closing parenthesis
 * @Return does not compile; diagnostic "Unmatched parenthesis"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
 * @Provenance sha256=8182105cb9380f58f9d0850cbb25f47431244b9680041ba410cce1f788dd365d; lines 667-669.
 * @Provenance CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
 * @Provenance Expected compile failure: "Unmatched parenthesis".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = (1 + 2;
}
