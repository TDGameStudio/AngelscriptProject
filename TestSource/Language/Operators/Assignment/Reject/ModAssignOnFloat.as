/**
 * Mod-assigning a float is rejected: the remainder operator applies to integers
 * only. This file is the illegal program itself; do not convert the operands,
 * since the non-integer operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ModAssignOnFloat
 * @Harness CompileReject
 * @Tag Language.Operators.ModAssignOnFloat
 * @Kind CompileReject
 * @Covers Operators.Assignment
 * @Inputs float X = 1.0f; X %= 2.0f;
 * @Return does not compile; diagnostic "Mod-assign on float"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
 * @Provenance sha256=223bc510bde708c6ae0bbbf89514ef640e18c74dd635481148d7136a4dfd4b72; lines 549-551.
 * @Provenance Expected compile failure: "Mod-assign on float".
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: float %= is allowed).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	float X = 1.0f;
	X %= 2.0f;
}
