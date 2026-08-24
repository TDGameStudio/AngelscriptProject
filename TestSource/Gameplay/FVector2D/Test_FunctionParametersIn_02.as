// Theme: Gameplay.FVector2D. Isolated compile-fail: FVector2D.Length() alias.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersIn
// CompileAndExpectFailure diagnostic: No matching signatures to
// 'FVector2D::Length()'. CSV Positive; C++ does not compile. DiagnosticOnly.
// Do not add extra declarations.

float TryVectorLength(FVector2D&in v)
{
	return v.Length();
}
