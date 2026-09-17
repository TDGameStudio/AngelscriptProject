/**
 * @version v1
 * @summary The legacy DrawDebugSphere parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugSphereUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugSphere parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugSphereUnsupported and expects the diagnostic to name.
 * @topic Negative
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
/** @end */
