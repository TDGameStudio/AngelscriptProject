// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugCoordinateSystem parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugCoordinateSystem (size/persistence/depth/thickness not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugCoordinateSystem.

void TryCoordinateSystemParameters()
{
	DrawDebugCoordinateSystem(FVector(0.0, 0.0, 0.0), FRotator(0.0, 90.0, 0.0), 25.0f, true, 5.0f, 3, 2.0f);
}
