// Theme: Gameplay.FVector. Isolated compile-fail: FVector.Length() alias.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersIn
// CompileAndExpectFailure diagnostic: No matching signatures to
// 'FVector::Length()'. CSV Positive; C++ does not compile. DiagnosticOnly.
// Do not add extra declarations.

float TryVectorLength(FVector&in v)
{
	return v.Length();
}
