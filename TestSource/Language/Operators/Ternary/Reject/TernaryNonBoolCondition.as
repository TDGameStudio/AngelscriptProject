/**
 * An integer ternary condition is rejected: the condition must be boolean, and
 * this fork does not treat a non-zero integer as true. This file is the
 * illegal program itself; do not wrap the integer in a comparison, since the
 * non-bool condition is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryNonBoolCondition
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryNonBoolCondition
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs 5 ? 1 : 0 assigned to an int
 * @Return does not compile; diagnostic "non-bool ternary condition (int 5)"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_NonBool; lines 594-596;
 * @Provenance sha256=4affb84b8079ee3bd4cd15f600eba559c619346e3ac10773a57291fc0195b0f1.
 * @Provenance Expected diagnostic: non-bool ternary condition (int 5).
 * @Provenance Do not wrap 5 in a comparison that would make this compile. DiagnosticOnly.
 */

void Test()
{
	int X = 5 ? 1 : 0;
}
