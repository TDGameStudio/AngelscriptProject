// Theme: Gameplay.FVector. Isolated compile-fail: | ^ and static product APIs.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorDotAndCross
// CompileAndExpectFailure. CSV NegativeDiagnostic. DiagnosticOnly.
// Do not add extra declarations that would compile this away.

void TryUnsupportedVectorProducts()
{
	FVector A = FVector(1, 0, 0);
	FVector B = FVector(0, 1, 0);
	float Dot = A | B;
	FVector Cross = A ^ B;
	float StaticDot = FVector::DotProduct(A, B);
	FVector StaticCross = FVector::CrossProduct(A, B);
}
