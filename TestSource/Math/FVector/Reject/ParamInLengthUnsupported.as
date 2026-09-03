/**
 * FVector::Length is not bound, so calling it through an `&in` parameter fails to
 * compile. C++ compiles this as the module ASCovFVectorFunc_ParamInLengthUnsupported and
 * expects a diagnostic naming FVector::Length. The CSV Positive label is wrong; C++ does
 * not compile this.
 *
 * @Theme Math.FVector
 * @Subject FVector.ParamInLengthUnsupported
 * @Harness CompileReject
 * @Tag Math.FVector.ParamInLengthUnsupported
 * @Provenance Theme: Gameplay.FVector. Isolated compile-fail: FVector.Length() alias.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersIn
 * @Provenance CompileAndExpectFailure diagnostic: No matching signatures to
 * @Provenance 'FVector::Length()'. CSV Positive; C++ does not compile. DiagnosticOnly.
 * @Provenance Do not add extra declarations.
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
