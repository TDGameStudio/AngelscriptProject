/**
 * Applying logical not to an integer is rejected: the operand must be boolean.
 * This file is the illegal program itself; do not convert it, since the
 * non-boolean operand is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalNotOnInteger
 * @Harness CompileReject
 * @Tag Language.Operators.LogicalNotOnInteger
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs !5 assigned to an int
 * @Return does not compile; diagnostic "Logical NOT on integer"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=602fc43ada2fb2e42b7ddaabc685c184e12c29d59454c49b0fc5f594f6e13090; lines 324-326.
 * @Provenance Expected compile failure: "Logical NOT on integer".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	int X = !5;
}
