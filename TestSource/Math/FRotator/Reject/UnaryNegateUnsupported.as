/**
 * Unary negate is not bound on FRotator, so this program is rejected. C++ compiles it as
 * the module ASCovFRotatorExpr_UnaryNegateUnsupported and expects a diagnostic naming
 * opNeg. The CSV NegativeDiagnostic label is correct here.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.UnaryNegateUnsupported
 * @Harness CompileReject
 * @Tag Math.FRotator.UnaryNegateUnsupported
 * @Provenance Theme: Gameplay.FRotator. Isolated compile-fail: unary negate is unbound.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorUnsupportedOperators
 * @Provenance CompileAndExpectFailure fragment: Function 'opNeg()' not found
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryNegate.
 */

/**
 * The isolated failing program: unary negate has no script-facing signature on FRotator.
 *
 * @Kind CompileReject
 * @Covers FRotator.UnaryNegateUnsupported
 * @Inputs none
 * @Return does not compile; opNeg is not bound
 */
FRotator TryNegate()
{
	FRotator Rotator = FRotator(10, 20, 30);
	return -Rotator;
}
