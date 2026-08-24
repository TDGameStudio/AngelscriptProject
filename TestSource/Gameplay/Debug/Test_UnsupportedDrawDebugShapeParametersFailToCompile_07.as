// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugPoint parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugPoint (size/persistence/depth not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugPoint.

void TryPointParameters()
{
	DrawDebugPoint(FVector(0.0, 0.0, 0.0), 8.0f, FLinearColor::White, true, 5.0f, 3);
}
