/**
 * A bitwise or on two floats is rejected: bitwise operators apply to integers
 * only. This file is the illegal program itself; do not convert the operands,
 * since the non-integer operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseOrOnFloat
 * @Harness CompileReject
 * @Tag Language.Operators.BitwiseOrOnFloat
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs 1.0f | 2.0f assigned to a float
 * @Return does not compile; diagnostic "Bitwise OR on float"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=68ad17fe2c5fbd6a4cbe468cf9eda0254321d90b1e731afd7638010dd6bfc01f; lines 233-235.
 * @Provenance Expected compile failure: "Bitwise OR on float".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	float X = 1.0f | 2.0f;
}
