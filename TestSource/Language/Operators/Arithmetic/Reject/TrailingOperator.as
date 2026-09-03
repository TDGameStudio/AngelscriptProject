/**
 * An expression ending in a binary operator is rejected: the operator has no
 * right operand. This file is the illegal program itself; do not supply the
 * operand, since the trailing operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TrailingOperator
 * @Harness CompileReject
 * @Tag Language.Operators.TrailingOperator
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs 1 +; with no right operand
 * @Return does not compile; diagnostic "Trailing operator"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
 * @Provenance sha256=bbaedb1e1de68d626523e025069f9ee53cf855c0a52725234d0236f190ea4f8e; lines 681-683.
 * @Provenance CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
 * @Provenance Expected compile failure: "Trailing operator".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = 1 +;
}
