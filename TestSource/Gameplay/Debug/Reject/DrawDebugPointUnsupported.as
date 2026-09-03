/**
 * The legacy DrawDebugPoint parameter list is not exposed to script, so this program
 * is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugPointUnsupported
 * and expects the diagnostic to name DrawDebugPoint.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugPointUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.DrawDebugPointUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugPoint parameters.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
 * @Provenance Expected diagnostic: DrawDebugPoint (size/persistence/depth not AS-facing).
 * @Provenance DiagnosticOnly. Do not drop DrawDebugPoint.
 */

/**
 * The isolated failing program: DrawDebugPoint has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugPointUnsupported
 * @Inputs none
 * @Return does not compile; the size, persistence and depth parameters are not AS-facing
 */
void TryPointParameters()
{
	DrawDebugPoint(FVector(0.0, 0.0, 0.0), 8.0f, FLinearColor::White, true, 5.0f, 3);
}
