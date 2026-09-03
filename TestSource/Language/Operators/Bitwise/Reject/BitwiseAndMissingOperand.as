/**
 * A bitwise and with no right operand is rejected: both operands are required.
 * This file is the illegal program itself; do not supply the operand, since the
 * missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitwiseAndMissingOperand
 * @Harness CompileReject
 * @Tag Language.Operators.BitwiseAndMissingOperand
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs 0xFF & with no right operand
 * @Return does not compile; diagnostic "Missing operand in bitwise AND"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=27b6f684baf2d29637c2142cd223017717be507bc2fb4c581d615e2e947cfdb1; lines 254-256.
 * @Provenance Expected compile failure: "Missing operand in bitwise AND".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = 0xFF & ;
}
