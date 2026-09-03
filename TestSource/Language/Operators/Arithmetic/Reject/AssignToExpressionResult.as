/**
 * Assigning to the result of an addition is rejected: the result is not an
 * lvalue. This file is the illegal program itself; do not assign to one of the
 * operands instead, since the expression target is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.AssignToExpressionResult
 * @Harness CompileReject
 * @Tag Language.Operators.AssignToExpressionResult
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs (A + B) = 5 where both are ints
 * @Return does not compile; diagnostic "Assign to expression result"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=2a08aa3a58b040cf26588ad9930f93bf4110cbf3d648c55e19893d59410ba150; lines 160-162.
 * @Provenance Expected compile failure: "Assign to expression result".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int A = 1;
	int B = 2;
	(A + B) = 5;
}
