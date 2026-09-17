/**
 * @version v1
 * @summary FVector2D instantiations that must not compile.
 * @topic Unreal
 * @topic FVector2D
 *
 * construct-unsupported
 * dot-operator-unsupported
 * param-in-length-unsupported
 * static-distance-unsupported
 */
/**
 * @begin construct-unsupported
 * @summary The isolated failing program: the single-value constructor and the unbound constants have no script-facing signatures.
 * @topic Negative
 */
void TryUnsupportedVector2DConstruction()
{
	FVector2D Single = FVector2D(5.0);
	FVector2D One = FVector2D::One;
	FVector2D UnitX = FVector2D::UnitX;
	FVector2D UnitY = FVector2D::UnitY;
}
/** @end */
/**
 * @begin dot-operator-unsupported
 * @summary The FVector2D `|` operator is not bound, so this program is rejected.
 * @topic Negative
 */
/**
 * The isolated failing program: the bitwise-or spelling of a 2D dot product is not bound.
 *
 * @Kind CompileReject
 * @Covers FVector2D.DotOperatorUnsupported
 * @Inputs none
 * @Return does not compile; FVector2D | FVector2D is not an operator
 */
float TryDotOperator()
{
	FVector2D A = FVector2D(1.0, 0.0);
	FVector2D B = FVector2D(0.0, 1.0);
	return A | B;
}
/** @end */
/**
 * @begin param-in-length-unsupported
 * @summary FVector2D::Length is not bound, so calling it through an `&in` parameter fails to compile.
 * @topic Negative
 */
/**
 * The isolated failing program: Length has no script-facing signature, so the body cannot
 * compile even though the parameter direction itself is well formed.
 *
 * @Kind CompileReject
 * @Covers FVector2D.ParamInLengthUnsupported
 * @Inputs a vector passed by read-only reference
 * @Return does not compile; FVector2D::Length is not bound
 * @Param v the vector whose length is requested
 */
float TryVectorLength(FVector2D&in v)
{
	return v.Length();
}
/** @end */
/**
 * @begin static-distance-unsupported
 * @summary The static FVector2D::Distance helper is not bound, so this program is rejected.
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
