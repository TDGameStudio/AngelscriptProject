// Theme: Gameplay.FVector. Isolated compile-fail: Length/SquaredLength aliases.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorMethods
// CompileAndExpectFailure for Length(), SquaredLength(), GetNormalized(),
// FVector::Distance, Dot, Cross. CSV NegativeDiagnostic. DiagnosticOnly.
// Do not add extra declarations.

void TryUnsupportedVectorMethodAliases()
{
	FVector A = FVector(3, 4, 0);
	FVector B = FVector(1, 0, 0);
	float Length = A.Length();
	float SquaredLength = A.SquaredLength();
	FVector Normal = A.GetNormalized();
	float Distance = FVector::Distance(A, B);
	float Dot = A.Dot(B);
	FVector Cross = A.Cross(B);
}
