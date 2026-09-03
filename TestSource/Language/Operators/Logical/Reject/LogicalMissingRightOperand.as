/**
 * A logical and with no right operand is rejected: both operands are required.
 * This file is the illegal program itself; do not supply the operand, since the
 * missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalMissingRightOperand
 * @Harness CompileReject
 * @Tag Language.Operators.LogicalMissingRightOperand
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs true && with no right operand
 * @Return does not compile; diagnostic "Missing right operand"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=bba1fbe0d0d63c9df1c2b11e826c9ddcc6d476d81ab7176987407d79a6b1a04c; lines 331-333.
 * @Provenance Expected compile failure: "Missing right operand".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	bool X = true && ;
}
