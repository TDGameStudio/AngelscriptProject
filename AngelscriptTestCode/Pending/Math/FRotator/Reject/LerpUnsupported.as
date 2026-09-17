/**
 * @version v1
 * @summary FRotator::Lerp is not bound, so this program is rejected. C++ compiles it as the module ASCovFRotatorExpr_LerpUnsupported and expects a diagnostic naming FRotator::Lerp. The CSV NegativeDiagnostic label is correct here.
 * @topic Math
 */
/**
 * @version root
 * @summary FRotator::Lerp is not bound, so this program is rejected. C++ compiles it as the module ASCovFRotatorExpr_LerpUnsupported and expects a diagnostic naming FRotator::Lerp. The CSV NegativeDiagnostic label is correct here.
 * @topic Negative
 */
/**
 * The isolated failing program: the static Lerp helper has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers FRotator.LerpUnsupported
 * @Inputs none
 * @Return does not compile; FRotator::Lerp is not bound
 */
FRotator TryLerp()
{
	FRotator A = FRotator(0, 0, 0);
	FRotator B = FRotator(90, 90, 90);
	return FRotator::Lerp(A, B, 0.5);
}
/** @end */
