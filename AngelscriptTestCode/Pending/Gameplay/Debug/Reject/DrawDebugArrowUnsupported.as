/**
 * @version v1
 * @summary The legacy DrawDebugArrow parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugArrowUnsupported and expects the diagnostic to name DrawDebugArrow.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugArrow parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugArrowUnsupported and expects the diagnostic to name DrawDebugArrow.
 * @topic Negative
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
/** @end */
