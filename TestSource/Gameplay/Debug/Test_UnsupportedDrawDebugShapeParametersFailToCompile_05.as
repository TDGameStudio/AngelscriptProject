// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugArrow parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugArrow (size/persistence/depth/thickness not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugArrow.

void TryArrowParameters()
{
	DrawDebugArrow(FVector(0.0, 0.0, 0.0), FVector(100.0, 0.0, 0.0), 12.0f, FLinearColor::Red, true, 5.0f, 3, 2.0f);
}
