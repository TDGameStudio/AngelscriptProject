// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugBox parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugBox (size/persistence/depth/thickness not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugBox.

void TryBoxParameters()
{
	DrawDebugBox(FVector(0.0, 0.0, 0.0), FVector(50.0, 25.0, 10.0), FLinearColor::Yellow, true, 5.0f, 3, 2.0f);
}
