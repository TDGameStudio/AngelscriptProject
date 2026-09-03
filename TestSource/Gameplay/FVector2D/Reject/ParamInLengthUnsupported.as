/**
 * FVector2D::Length is not bound, so calling it through an `&in` parameter fails to
 * compile. C++ compiles this as the module ASCovFVector2DFunc_ParamInLengthUnsupported and
 * expects a diagnostic naming FVector2D::Length. The CSV Positive label is wrong; C++ does
 * not compile this.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.ParamInLengthUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.FVector2D.ParamInLengthUnsupported
 * @Provenance Theme: Gameplay.FVector2D. Isolated compile-fail: FVector2D.Length() alias.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersIn
 * @Provenance CompileAndExpectFailure diagnostic: No matching signatures to
 * @Provenance 'FVector2D::Length()'. CSV Positive; C++ does not compile. DiagnosticOnly.
 * @Provenance Do not add extra declarations.
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
