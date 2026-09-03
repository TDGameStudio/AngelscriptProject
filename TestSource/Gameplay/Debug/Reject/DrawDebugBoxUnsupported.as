/**
 * The legacy DrawDebugBox parameter list is not exposed to script, so this program is
 * rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugBoxUnsupported and
 * expects the diagnostic to name DrawDebugBox.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugBoxUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.DrawDebugBoxUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugBox parameters.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
 * @Provenance Expected diagnostic: DrawDebugBox (size/persistence/depth/thickness not AS-facing).
 * @Provenance DiagnosticOnly. Do not drop DrawDebugBox.
 */

/**
 * The isolated failing program: DrawDebugBox has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugBoxUnsupported
 * @Inputs none
 * @Return does not compile; the size, persistence, depth and thickness parameters are not AS-facing
 */
void TryBoxParameters()
{
	DrawDebugBox(FVector(0.0, 0.0, 0.0), FVector(50.0, 25.0, 10.0), FLinearColor::Yellow, true, 5.0f, 3, 2.0f);
}
