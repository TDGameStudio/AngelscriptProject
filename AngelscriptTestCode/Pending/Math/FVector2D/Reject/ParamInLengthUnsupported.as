/**
 * @version v1
 * @summary FVector2D::Length is not bound, so calling it through an `&in` parameter fails to compile. C++ compiles this as the module ASCovFVector2DFunc_ParamInLengthUnsupported and expects a diagnostic naming FVector2D::Length.
 * @topic Math
 */
/**
 * @version root
 * @summary FVector2D::Length is not bound, so calling it through an `&in` parameter fails to compile. C++ compiles this as the module ASCovFVector2DFunc_ParamInLengthUnsupported and expects a diagnostic naming FVector2D::Length.
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
