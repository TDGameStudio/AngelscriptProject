// Theme: Gameplay.FVector2D. Isolated compile-fail: single-value ctor and aliases.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DConstruction
// CompileAndExpectFailure diagnostics: No matching signatures to
// 'FVector2D(const float)'; 'FVector2D::One' is not declared;
// 'FVector2D::UnitX' is not declared; 'FVector2D::UnitY' is not declared.
// CSV NegativeDiagnostic. DiagnosticOnly. Do not add extra declarations.

void TryUnsupportedVector2DConstruction()
{
	FVector2D Single = FVector2D(5.0);
	FVector2D One = FVector2D::One;
	FVector2D UnitX = FVector2D::UnitX;
	FVector2D UnitY = FVector2D::UnitY;
}
