/**
 * A string ternary condition is rejected: the condition must be boolean. This
 * file is the illegal program itself; do not compare the string, since the
 * non-bool condition is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryStringCondition
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryStringCondition
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs "yes" ? 1 : 0 assigned to an int
 * @Return does not compile; diagnostic "string as ternary condition"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_StrCond; lines 629-631;
 * @Provenance sha256=ae6d999058ae6eb6b184312d8718d16225782c309be40167b0b13cf32582a908.
 * @Provenance Expected diagnostic: string as ternary condition.
 * @Provenance Do not compare the string to make this compile. DiagnosticOnly.
 */

/** */
void Test()
{
	int X = "yes" ? 1 : 0;
}
