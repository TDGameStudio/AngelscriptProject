/**
 * The static FVector::Distance helper is not bound, so this program is rejected. C++
 * compiles it as the module ASCovFVectorFunc_StaticDistanceUnsupported and expects a
 * diagnostic naming FVector::Distance. The CSV Positive label is wrong; C++ does not
 * compile this.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.StaticDistanceUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FVector.StaticDistanceUnsupported
 * @Provenance Theme: Gameplay.FVector. Isolated compile-fail: static FVector::Distance.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersValue
 * @Provenance CompileAndExpectFailure diagnostic: No matching signatures to
 * @Provenance 'FVector::Distance(FVector, FVector)'. CSV Positive; C++ does not compile.
 * @Provenance DiagnosticOnly. Do not add extra declarations.
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
