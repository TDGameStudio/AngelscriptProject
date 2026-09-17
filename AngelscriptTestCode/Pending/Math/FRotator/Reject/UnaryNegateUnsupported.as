/**
 * @version v1
 * @summary Unary negate is not bound on FRotator, so this program is rejected. C++ compiles it as the module ASCovFRotatorExpr_UnaryNegateUnsupported and expects a diagnostic naming opNeg. The CSV NegativeDiagnostic label is.
 * @topic Math
 */
/**
 * @version root
 * @summary Unary negate is not bound on FRotator, so this program is rejected. C++ compiles it as the module ASCovFRotatorExpr_UnaryNegateUnsupported and expects a diagnostic naming opNeg. The CSV NegativeDiagnostic label is.
 * @topic Negative
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
/** @end */
