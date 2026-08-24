// Theme: Gameplay.FVector2D. Isolated compile-fail: static FVector2D::Distance.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersValue
// CompileAndExpectFailure diagnostic: No matching signatures to
// 'FVector2D::Distance(FVector2D, FVector2D)'. CSV Positive; C++ does not compile.
// DiagnosticOnly. Do not add extra declarations.

float TryStaticDistance(FVector2D A, FVector2D B)
{
	return FVector2D::Distance(A, B);
}
