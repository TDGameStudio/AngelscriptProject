/**
 * The legacy DrawDebugArrow parameter list is not exposed to script, so this program
 * is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugArrowUnsupported
 * and expects the diagnostic to name DrawDebugArrow.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugArrowUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.DrawDebugArrowUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugArrow parameters.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
 * @Provenance Expected diagnostic: DrawDebugArrow (size/persistence/depth/thickness not AS-facing).
 * @Provenance DiagnosticOnly. Do not drop DrawDebugArrow.
 */

/**
 * The isolated failing program: DrawDebugArrow has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugArrowUnsupported
 * @Inputs none
 * @Return does not compile; the size, persistence, depth and thickness parameters are not AS-facing
 */
void TryArrowParameters()
{
	DrawDebugArrow(FVector(0.0, 0.0, 0.0), FVector(100.0, 0.0, 0.0), 12.0f, FLinearColor::Red, true, 5.0f, 3, 2.0f);
}
