/**
 * A comparison with no right operand is rejected: both sides are required.
 * This file is the illegal program itself; do not supply the operand, since
 * the missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ComparisonMissingRightOperand
 * @Harness CompileReject
 * @Tag Language.Operators.ComparisonMissingRightOperand
 * @Kind CompileReject
 * @Covers Operators.Comparison
 * @Inputs 1 == with no right operand
 * @Return does not compile; diagnostic "Missing right operand"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
 * @Provenance sha256=ce2d96b2b30188b97978b809da9d39de65ae59e403e17deae3f247a5dd64c80a; lines 411-413.
 * @Provenance Expected compile failure: "Missing right operand".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	bool X = (1 == );
}
