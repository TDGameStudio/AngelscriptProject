// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugLine parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugLine (not AS-facing on this branch).
// DiagnosticOnly. Do not drop DrawDebugLine.

void TryLineParameters()
{
	DrawDebugLine(FVector(0.0, 0.0, 0.0), FVector(100.0, 0.0, 0.0), FLinearColor::Red, true, 5.0f, 3, 2.0f);
}
