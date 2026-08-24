// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugSphere parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugSphere (size/persistence/depth/thickness not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugSphere.

void TrySphereParameters()
{
	DrawDebugSphere(FVector(0.0, 0.0, 0.0), 50.0f, 12, FLinearColor::Green, true, 5.0f, 3, 2.0f);
}
