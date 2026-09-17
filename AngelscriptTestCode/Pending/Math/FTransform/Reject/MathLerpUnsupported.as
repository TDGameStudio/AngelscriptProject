/**
 * @version v1
 * @summary Math::Lerp is not bound for FTransform, so this program is rejected. C++ compiles it as the module ASCovFTransformExpr_MathLerpUnsupported and expects a diagnostic naming the signature. Blend and BlendWith are the bound.
 * @topic Math
 */
/**
 * @version root
 * @summary Math::Lerp is not bound for FTransform, so this program is rejected. C++ compiles it as the module ASCovFTransformExpr_MathLerpUnsupported and expects a diagnostic naming the signature. Blend and BlendWith are the bound.
 * @topic Negative
 */
/**
 * The isolated failing program: Math::Lerp has no overload taking two transforms.
 *
 * @Kind CompileReject
 * @Covers FTransform.MathLerpUnsupported
 * @Inputs none
 * @Return does not compile; Math::Lerp is not bound for FTransform
 */
FTransform TryMathLerp()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	return Math::Lerp(A, B, 0.5f);
}
/** @end */
