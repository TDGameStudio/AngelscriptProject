/**
 * FRotator::Lerp is not bound, so this program is rejected. C++ compiles it as the module
 * ASCovFRotatorExpr_LerpUnsupported and expects a diagnostic naming FRotator::Lerp. The
 * CSV NegativeDiagnostic label is correct here.
 *
 * @Theme Gameplay.FRotator
 * @Subject FRotator.LerpUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FRotator.LerpUnsupported
 * @Provenance Theme: Gameplay.FRotator. Isolated compile-fail: FRotator::Lerp is unbound.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorUnsupportedStaticMethods
 * @Provenance CompileAndExpectFailure fragment: No matching signatures to 'FRotator::Lerp
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryLerp.
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
