/**
 * @version v1
 * @summary The legacy DrawDebugCoordinateSystem parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugCoordinateSystemUnsupported and expects the diagnostic to.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugCoordinateSystem parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugCoordinateSystemUnsupported and expects the diagnostic to.
 * @topic Negative
 */
/**
 * The isolated failing program: DrawDebugCoordinateSystem has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugCoordinateSystemUnsupported
 * @Inputs none
 * @Return does not compile; the size, persistence, depth and thickness parameters are not AS-facing
 */
void TryCoordinateSystemParameters()
{
	DrawDebugCoordinateSystem(FVector(0.0, 0.0, 0.0), FRotator(0.0, 90.0, 0.0), 25.0f, true, 5.0f, 3, 2.0f);
}
/** @end */
