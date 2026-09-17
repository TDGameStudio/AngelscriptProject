/**
 * @version v1
 * @summary The legacy DrawDebugBox parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugBoxUnsupported and expects the diagnostic to name DrawDebugBox.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugBox parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugBoxUnsupported and expects the diagnostic to name DrawDebugBox.
 * @topic Negative
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
/** @end */
