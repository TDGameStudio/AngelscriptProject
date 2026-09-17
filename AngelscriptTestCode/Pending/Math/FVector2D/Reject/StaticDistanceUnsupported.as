/**
 * @version v1
 * @summary The static FVector2D::Distance helper is not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DFunc_StaticDistanceUnsupported and expects a diagnostic naming FVector2D::Distance. The CSV.
 * @topic Math
 */
/**
 * @version root
 * @summary The static FVector2D::Distance helper is not bound, so this program is rejected. C++ compiles it as the module ASCovFVector2DFunc_StaticDistanceUnsupported and expects a diagnostic naming FVector2D::Distance. The CSV.
 * @topic Negative
 */
/**
 * The isolated failing program: the static Distance helper has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers FVector2D.StaticDistanceUnsupported
 * @Inputs two vectors to measure between
 * @Return does not compile; FVector2D::Distance is not bound
 * @Param A the first vector
 * @Param B the second vector
 */
float TryStaticDistance(FVector2D A, FVector2D B)
{
	return FVector2D::Distance(A, B);
}
/** @end */
