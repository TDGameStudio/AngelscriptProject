/**
 * @version v1
 * @summary The legacy DrawDebugPoint parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugPointUnsupported and expects the diagnostic to name DrawDebugPoint.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugPoint parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugPointUnsupported and expects the diagnostic to name DrawDebugPoint.
 * @topic Negative
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
/** @end */
