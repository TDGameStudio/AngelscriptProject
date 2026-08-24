// Theme: Gameplay.FTransform. Isolated compile-fail: Math::Lerp(FTransform) is unbound.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInterpolation (failing block)
// CSV Positive; C++ CompileAndExpectFailure.
// Diagnostic: No matching signatures to 'Math::Lerp(FTransform, FTransform, const float32)'
// DiagnosticOnly. Do not drop TryMathLerp.

FTransform TryMathLerp()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	return Math::Lerp(A, B, 0.5f);
}
