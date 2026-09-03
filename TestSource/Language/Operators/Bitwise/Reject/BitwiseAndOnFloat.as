/**
 * A bitwise and on two floats is rejected: bitwise operators apply to integers
 * only. This file is the illegal program itself; do not convert the operands,
 * since the non-integer operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseAndOnFloat
 * @Harness CompileReject
 * @Tag Language.Operators.BitwiseAndOnFloat
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs 1.0f & 2.0f assigned to a float
 * @Return does not compile; diagnostic "Bitwise AND on float"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=3e7f73cab08462b57539981bd227e20ef3d0d76f07187ba8b5245a33be827b0b; lines 226-228.
 * @Provenance Expected compile failure: "Bitwise AND on float".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	float X = 1.0f & 2.0f;
}
