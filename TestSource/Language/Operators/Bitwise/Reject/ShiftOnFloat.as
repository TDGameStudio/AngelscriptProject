/**
 * Shifting a float is rejected: shift operators apply to integers only. This
 * file is the illegal program itself; do not convert the operand, since the
 * non-integer operand is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ShiftOnFloat
 * @Harness CompileReject
 * @Tag Language.Operators.ShiftOnFloat
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs 1.0f << 2 assigned to a float
 * @Return does not compile; diagnostic "Shift on float"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=bf5a24506476aaf34304b61aec13293a25625234150dad0e749fd1bb90a20359; lines 240-242.
 * @Provenance Expected compile failure: "Shift on float".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	float X = 1.0f << 2;
}
