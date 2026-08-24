// Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugCapsule parameters.
// C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
// Expected diagnostic: DrawDebugCapsule (radius/size/persistence/depth/thickness not AS-facing).
// DiagnosticOnly. Do not drop DrawDebugCapsule.

void TryCapsuleParameters()
{
	DrawDebugCapsule(FVector(0.0, 0.0, 0.0), 88.0f, 34.0f, FQuat::Identity, FLinearColor::Green, true, 5.0f, 3, 2.0f);
}
