/**
 * @version v1
 * @summary The native SCOPE_CYCLE_COUNTER macro is not visible to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ScopeCycleCounterUnsupported and expects the diagnostic to name the stat it.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The native SCOPE_CYCLE_COUNTER macro is not visible to script, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ScopeCycleCounterUnsupported and expects the diagnostic to name the stat it.
 * @topic Negative
 */
/**
 * The isolated failing program: the SCOPE_CYCLE_COUNTER macro has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Debug.ScopeCycleCounterUnsupported
 * @Inputs none
 * @Return does not compile; SCOPE_CYCLE_COUNTER is a native macro
 */
void TryNativeProfilerMacro()
{
	SCOPE_CYCLE_COUNTER(STAT_CoverageDebugAndLogging);
}
/** @end */
