/**
 * The legacy DrawDebugSphere parameter list is not exposed to script, so this program
 * is rejected. C++ compiles it as the module
 * ASCoverageDebug_DrawDebugSphereUnsupported and expects the diagnostic to name
 * DrawDebugSphere.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugSphereUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.DrawDebugSphereUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugSphere parameters.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
 * @Provenance Expected diagnostic: DrawDebugSphere (size/persistence/depth/thickness not AS-facing).
 * @Provenance DiagnosticOnly. Do not drop DrawDebugSphere.
 */

/**
 * The isolated failing program: DrawDebugSphere has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugSphereUnsupported
 * @Inputs none
 * @Return does not compile; the size, persistence, depth and thickness parameters are not AS-facing
 */
void TrySphereParameters()
{
	DrawDebugSphere(FVector(0.0, 0.0, 0.0), 50.0f, 12, FLinearColor::Green, true, 5.0f, 3, 2.0f);
}
