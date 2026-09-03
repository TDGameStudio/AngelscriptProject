/**
 * Shift-assigning a float is rejected: shift operators apply to integers only.
 * This file is the illegal program itself; do not convert the operand, since
 * the non-integer operand is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ShiftAssignOnFloat
 * @Harness CompileReject
 * @Tag Language.Operators.ShiftAssignOnFloat
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs float X = 1.0f; X <<= 2;
 * @Return does not compile; diagnostic "Shift-assign on float"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=74a0aaa31ac31a604361725725a7875758d563cbca3937a648ede4bc48a9d31e; lines 540-542.
 * @Provenance Expected compile failure: "Shift-assign on float".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	float X = 1.0f;
	X <<= 2;
}
