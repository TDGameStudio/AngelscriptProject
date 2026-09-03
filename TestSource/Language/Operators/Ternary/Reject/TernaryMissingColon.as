/**
 * A ternary with no colon or false branch is rejected: both branches are
 * required. This file is the illegal program itself; do not add the colon and
 * false branch, since the missing ones are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryMissingColon
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryMissingColon
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs true ? 1 with no colon
 * @Return does not compile; diagnostic "ternary without colon"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_NoColon; lines 608-610;
 * @Provenance sha256=4bacce4cc4694010d86312dd07466f8b197bef663c5a9482b9f708e2e3d2e0cb.
 * @Provenance Expected diagnostic: ternary without colon.
 * @Provenance Do not add : 0 that would make this compile. DiagnosticOnly.
 */

/** */
void Test()
{
	int X = true ? 1;
}
