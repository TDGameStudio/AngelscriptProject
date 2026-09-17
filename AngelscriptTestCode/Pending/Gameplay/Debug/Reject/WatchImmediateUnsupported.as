/**
 * @version v1
 * @summary Watch and EvaluateImmediate are debugger-client features rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_WatchImmediateUnsupported and expects the diagnostic to.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Watch and EvaluateImmediate are debugger-client features rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_WatchImmediateUnsupported and expects the diagnostic to.
 * @topic Negative
 */
/**
 * The isolated failing program: Watch and EvaluateImmediate have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.WatchImmediateUnsupported
 * @Inputs none
 * @Return does not compile; watch and immediate-window evaluation belong to the debugger client
 */
void TryWatchAndImmediate()
{
	Watch("Value");
	EvaluateImmediate("Value + 1");
}
/** @end */
