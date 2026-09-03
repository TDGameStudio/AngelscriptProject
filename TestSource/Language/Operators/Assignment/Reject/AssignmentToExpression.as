/**
 * Assigning to an arithmetic expression is rejected: the result of an addition
 * is not an lvalue. This file is the illegal program itself; do not assign to
 * one of the operands instead, since the expression target is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignmentToExpression
 * @Harness CompileReject
 * @Tag Language.Operators.AssignmentToExpression
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs (X + Y) = 5 where both are ints
 * @Return does not compile; diagnostic "Assign to expression"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=0a5fe6846d56036ca14cace52ae6789aec2af74f5cec5114ca3e88e9e087d2f7; lines 533-535.
 * @Provenance Expected compile failure: "Assign to expression".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = 0;
	int Y = 0;
	(X + Y) = 5;
}
