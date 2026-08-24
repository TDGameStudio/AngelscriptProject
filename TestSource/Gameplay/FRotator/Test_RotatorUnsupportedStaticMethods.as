// Theme: Gameplay.FRotator. Isolated compile-fail: FRotator::Lerp is unbound.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorUnsupportedStaticMethods
// CompileAndExpectFailure fragment: No matching signatures to 'FRotator::Lerp
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop TryLerp.

FRotator TryLerp()
{
	FRotator A = FRotator(0, 0, 0);
	FRotator B = FRotator(90, 90, 90);
	return FRotator::Lerp(A, B, 0.5);
}
