// Theme: Gameplay.FVector. Isolated compile-fail: UnitX/UnitY/UnitZ aliases.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorConstruction
// CompileAndExpectFailure diagnostics: No matching signatures to
// 'FVector::UnitX()', 'FVector::UnitY()', 'FVector::UnitZ()'.
// CSV NegativeDiagnostic. DiagnosticOnly. Do not add extra declarations.

void TryUnsupportedUnitFunctions()
{
	FVector UnitX = FVector::UnitX();
	FVector UnitY = FVector::UnitY();
	FVector UnitZ = FVector::UnitZ();
}
