/**
 * A float ternary condition is rejected: the condition must be boolean. This
 * file is the illegal program itself; do not compare the float, since the
 * non-bool condition is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryFloatCondition
 * @Harness CompileReject
 * @Tag Language.Operators.TernaryFloatCondition
 * @Kind CompileReject
 * @Covers Operators.Ternary
 * @Inputs 1.0f ? 1 : 0 assigned to an int
 * @Return does not compile; diagnostic "float as ternary condition"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile TernN_FloatCond; lines 622-624;
 * @Provenance sha256=b9640d4f2b52feb6fc94892395fa86bd0cdbf7ff64be1a0eb701db98374f35e9.
 * @Provenance Expected diagnostic: float as ternary condition.
 * @Provenance Do not compare the float to make this compile. DiagnosticOnly.
 */

void Test()
{
	int X = 1.0f ? 1 : 0;
}
