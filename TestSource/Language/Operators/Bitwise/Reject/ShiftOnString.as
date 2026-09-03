/**
 * Shifting a string is rejected: shift operators apply to integers only. This
 * file is the illegal program itself; do not substitute a different operand,
 * since the string is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ShiftOnString
 * @Harness CompileReject
 * @Tag Language.Operators.ShiftOnString
 * @Kind CompileReject
 * @Covers Operators.Bitwise
 * @Inputs "abc" >> 2
 * @Return does not compile; diagnostic "Shift on string"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
 * @Provenance sha256=fdf1b9d0fb6535f005c6af04f0c88544f874126cd71630aad3b206251722c02c; lines 271-273.
 * @Provenance Expected compile failure: "Shift on string".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	auto X = "abc" >> 2;
}
