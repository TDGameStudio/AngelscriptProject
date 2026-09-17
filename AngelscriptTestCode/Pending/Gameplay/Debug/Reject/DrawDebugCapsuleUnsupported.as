/**
 * @version v1
 * @summary The legacy DrawDebugCapsule parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugCapsuleUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The legacy DrawDebugCapsule parameter list is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_DrawDebugCapsuleUnsupported and expects the diagnostic to name.
 * @topic Negative
 */
/**
 * The isolated failing program: DrawDebugCapsule has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.DrawDebugCapsuleUnsupported
 * @Inputs none
 * @Return does not compile; the radius, size, persistence, depth and thickness parameters are not AS-facing
 */
void TryCapsuleParameters()
{
	DrawDebugCapsule(FVector(0.0, 0.0, 0.0), 88.0f, 34.0f, FQuat::Identity, FLinearColor::Green, true, 5.0f, 3, 2.0f);
}
/** @end */
