/**
 * Applying logical or to two strings is rejected: the operands must be boolean.
 * This file is the illegal program itself; do not convert them, since the
 * non-boolean operands are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalOrOnStrings
 * @Harness CompileReject
 * @Tag Language.Operators.LogicalOrOnStrings
 * @Kind CompileReject
 * @Covers Operators.Logical
 * @Inputs "a" || "b"
 * @Return does not compile; diagnostic "Logical OR on strings"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
 * @Provenance sha256=55246348843ead21fa6e789e2f24aaa0a5985b91142e3e4442bd2891e379b8ea; lines 345-347.
 * @Provenance Expected compile failure: "Logical OR on strings".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	auto X = "a" || "b";
}
