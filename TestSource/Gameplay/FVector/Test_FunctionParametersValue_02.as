// Theme: Gameplay.FVector. Isolated compile-fail: static FVector::Distance.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersValue
// CompileAndExpectFailure diagnostic: No matching signatures to
// 'FVector::Distance(FVector, FVector)'. CSV Positive; C++ does not compile.
// DiagnosticOnly. Do not add extra declarations.

float TryStaticDistance(FVector A, FVector B)
{
	return FVector::Distance(A, B);
}
