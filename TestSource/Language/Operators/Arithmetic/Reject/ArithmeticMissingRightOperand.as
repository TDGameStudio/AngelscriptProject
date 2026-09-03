/**
 * An addition with no right operand is rejected: both operands are required.
 * This file is the illegal program itself; do not supply the operand, since the
 * missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ArithmeticMissingRightOperand
 * @Harness CompileReject
 * @Tag Language.Operators.ArithmeticMissingRightOperand
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs 1 + with no right operand
 * @Return does not compile; diagnostic "Missing right operand"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=183c5b89f09586ef97250bdc0350565556191d99752de79de69bbff2f0b80bce; lines 128-130.
 * @Provenance Expected compile failure: "Missing right operand".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int X = 1 + ;
}
