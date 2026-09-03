/**
 * A triple ampersand is rejected: this language has no such operator, only &&
 * and the bitwise &. This file is the illegal program itself; do not reduce it
 * to &&, since the triple form is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TripleAmpersandOperator
 * @Harness CompileReject
 * @Tag Language.Operators.TripleAmpersandOperator
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs true &&& false
 * @Return does not compile; diagnostic "Triple & is invalid"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=6569005458d973229ac7721ed5029db5393651d479219d24c063e0cc4690c5b3; lines 338-340.
 * @Provenance Expected compile failure: "Triple & is invalid".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	bool X = true &&& false;
}
