/**
 * @version v1
 * @summary The static FVector::Distance helper is not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorFunc_StaticDistanceUnsupported and expects a diagnostic naming FVector::Distance. The CSV Positive.
 * @topic Math
 */
/**
 * @version root
 * @summary The static FVector::Distance helper is not bound, so this program is rejected. C++ compiles it as the module ASCovFVectorFunc_StaticDistanceUnsupported and expects a diagnostic naming FVector::Distance. The CSV Positive.
 * @topic Negative
 */
/**
 * The isolated failing program: the static Distance helper has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers FVector.StaticDistanceUnsupported
 * @Inputs two vectors to measure between
 * @Return does not compile; FVector::Distance is not bound
 * @Param A the first vector
 * @Param B the second vector
 */
float TryStaticDistance(FVector A, FVector B)
{
	return FVector::Distance(A, B);
}
/** @end */
