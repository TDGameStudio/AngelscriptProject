/**
 * @version v1
 * @summary FVector instantiations that must not compile.
 * @topic Unreal
 * @topic FVector
 *
 * method-aliases-unsupported
 * param-in-length-unsupported
 * static-and-operator-products-unsupported
 * static-distance-unsupported
 * unit-functions-unsupported
 */
/**
 * @begin method-aliases-unsupported
 * @summary The isolated failing program: the method aliases have no script-facing signatures.
 * @topic Negative
 */
void TryUnsupportedVectorMethodAliases()
{
	FVector A = FVector(3, 4, 0);
	FVector B = FVector(1, 0, 0);
	float Length = A.Length();
	float SquaredLength = A.SquaredLength();
	FVector Normal = A.GetNormalized();
	float Distance = FVector::Distance(A, B);
	float Dot = A.Dot(B);
	FVector Cross = A.Cross(B);
}
/** @end */
/**
 * @begin param-in-length-unsupported
 * @summary FVector::Length is not bound, so calling it through an `&in` parameter fails to compile.
 * @topic Negative
 */
/**
 * The isolated failing program: Length has no script-facing signature, so the body cannot
 * compile even though the parameter direction itself is well formed.
 *
 * @Kind CompileReject
 * @Covers FVector.ParamInLengthUnsupported
 * @Inputs a vector passed by read-only reference
 * @Return does not compile; FVector::Length is not bound
 * @Param v the vector whose length is requested
 */
float TryVectorLength(FVector&in v)
{
	return v.Length();
}
/** @end */
/**
 * @begin static-and-operator-products-unsupported
 * @summary The isolated failing program: the product operators and static product helpers have no script-facing signatures.
 * @topic Negative
 */
void TryUnsupportedVectorProducts()
{
	FVector A = FVector(1, 0, 0);
	FVector B = FVector(0, 1, 0);
	float Dot = A | B;
	FVector Cross = A ^ B;
	float StaticDot = FVector::DotProduct(A, B);
	FVector StaticCross = FVector::CrossProduct(A, B);
}
/** @end */
/**
 * @begin static-distance-unsupported
 * @summary The static FVector::Distance helper is not bound, so this program is rejected.
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
/**
 * @begin unit-functions-unsupported
 * @summary The isolated failing program: the three unit-axis aliases have no script-facing signatures.
 * @topic Negative
 */
void TryUnsupportedUnitFunctions()
{
	FVector UnitX = FVector::UnitX();
	FVector UnitY = FVector::UnitY();
	FVector UnitZ = FVector::UnitZ();
}
/** @end */
