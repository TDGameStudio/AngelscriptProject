/**
 * Taking the remainder of two floats is rejected: the modulo operator applies
 * to integers only. This file is the illegal program itself; do not convert
 * the operands, since the non-integer operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.FloatModulo
 * @Harness CompileReject
 * @Tag Language.Operators.FloatModulo
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs 10.0f % 3.0f assigned to a float
 * @Return does not compile; diagnostic "Float modulo"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=198a78a1684413b01849cfb66b234243bb61b71afb727b72968d7d20517491d1; lines 119-121.
 * @Provenance Expected compile failure: "Float modulo".
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: float modulo is allowed).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	float X = 10.0f % 3.0f;
}
