/**
 * @version v1
 * @summary FRotator instantiations that must not compile.
 * @topic Unreal
 * @topic FRotator
 *
 * lerp-unsupported
 * unary-negate-unsupported
 */
/**
 * @begin lerp-unsupported
 * @summary FRotator::Lerp is not bound, so this program is rejected.
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
/**
 * @begin unary-negate-unsupported
 * @summary Unary negate is not bound on FRotator, so this program is rejected.
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
