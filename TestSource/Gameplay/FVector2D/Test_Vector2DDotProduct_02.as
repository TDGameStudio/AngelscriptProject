// Theme: Gameplay.FVector2D. Isolated compile-fail: FVector2D | operator.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DDotProduct
// CompileAndExpectFailure. CSV Positive; C++ does not compile. DiagnosticOnly.
// Do not add extra declarations that would compile this away.

float TryDotOperator()
{
	FVector2D A = FVector2D(1.0, 0.0);
	FVector2D B = FVector2D(0.0, 1.0);
	return A | B;
}
