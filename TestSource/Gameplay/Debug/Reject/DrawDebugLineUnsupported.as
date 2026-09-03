/**
 * The legacy DrawDebugLine parameter list is not exposed to script, so this program
 * is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugLineUnsupported
 * and expects the diagnostic to name DrawDebugLine.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugLineUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.DrawDebugLineUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: legacy DrawDebugLine parameters.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::UnsupportedDrawDebugShapeParametersFailToCompile
 * @Provenance Expected diagnostic: DrawDebugLine (not AS-facing on this branch).
 * @Provenance DiagnosticOnly. Do not drop DrawDebugLine.
 */

/**
 * The isolated failing program: DrawDebugLine has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugLineUnsupported
 * @Inputs none
 * @Return does not compile; the legacy DrawDebugLine parameters are not AS-facing
 */
void TryLineParameters()
{
	DrawDebugLine(FVector(0.0, 0.0, 0.0), FVector(100.0, 0.0, 0.0), FLinearColor::Red, true, 5.0f, 3, 2.0f);
}
