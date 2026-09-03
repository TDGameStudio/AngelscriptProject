/**
 * The static FVector2D::Distance helper is not bound, so this program is rejected. C++
 * compiles it as the module ASCovFVector2DFunc_StaticDistanceUnsupported and expects a
 * diagnostic naming FVector2D::Distance. The CSV Positive label is wrong; C++ does not
 * compile this.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.StaticDistanceUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FVector2D.StaticDistanceUnsupported
 * @Provenance Theme: Gameplay.FVector2D. Isolated compile-fail: static FVector2D::Distance.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersValue
 * @Provenance CompileAndExpectFailure diagnostic: No matching signatures to
 * @Provenance 'FVector2D::Distance(FVector2D, FVector2D)'. CSV Positive; C++ does not compile.
 * @Provenance DiagnosticOnly. Do not add extra declarations.
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
