/**
 * @version v1
 * @summary The legacy DrawDebugLine parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugLineUnsupported and expects the diagnostic to name DrawDebugLine.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugLine parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugLineUnsupported and expects the diagnostic to name DrawDebugLine.
 * @topic Negative
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
/** @end */
