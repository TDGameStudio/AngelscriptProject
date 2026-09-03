/**
 * Incrementing a literal is rejected: a literal has no storage to increment.
 * This file is the illegal program itself; do not bind the literal to a
 * variable, since the literal target is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.IncrementOnLiteral
 * @Harness CompileReject
 * @Tag Language.Operators.IncrementOnLiteral
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs ++5
 * @Return does not compile; diagnostic "Increment on literal"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=ccb5f2e6fb39e46cd474ed2899834701bf4910b1c6c439594646172303545a67; lines 136-138.
 * @Provenance Expected compile failure: "Increment on literal".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	++5;
}
