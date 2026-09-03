/**
 * Math::Lerp is not bound for FTransform, so this program is rejected. C++ compiles it as
 * the module ASCovFTransformExpr_MathLerpUnsupported and expects a diagnostic naming the
 * signature. Blend and BlendWith are the bound interpolation path and are covered
 * separately. The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Math.FTransform
 * @Subject FTransform.MathLerpUnsupported
 * @Harness CompileReject
 * @Tag Math.FTransform.MathLerpUnsupported
 * @Provenance Theme: Gameplay.FTransform. Isolated compile-fail: Math::Lerp(FTransform) is unbound.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInterpolation (failing block)
 * @Provenance CSV Positive; C++ CompileAndExpectFailure.
 * @Provenance Diagnostic: No matching signatures to 'Math::Lerp(FTransform, FTransform, const float32)'
 * @Provenance DiagnosticOnly. Do not drop TryMathLerp.
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
