/**
 * An expression starting with a binary operator is rejected: the operator has
 * no left operand. This file is the illegal program itself; do not supply the
 * operand, since the leading operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LeadingBinaryOperator
 * @Harness CompileReject
 * @Tag Language.Operators.LeadingBinaryOperator
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs * 2 with no left operand
 * @Return does not compile; diagnostic "Leading binary operator"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
 * @Provenance sha256=bbb5389e0885c41e441067e820b0db109c27321f9522e163b23d74cbe0872fef; lines 688-690.
 * @Provenance CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
 * @Provenance Expected compile failure: "Leading binary operator".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int X = * 2;
}
