/**
 * @version v1
 * @summary StepOver, StepInto and StepOut are driven by the debugger client rather than being script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_StepControlsUnsupported and expects the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary StepOver, StepInto and StepOut are driven by the debugger client rather than being script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_StepControlsUnsupported and expects the.
 * @topic Negative
 */
/**
 * The isolated failing program: the stepping controls have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.StepControlsUnsupported
 * @Inputs none
 * @Return does not compile; stepping is driven by debugger clients
 */
void TryStepControls()
{
	StepOver();
	StepInto();
	StepOut();
}
/** @end */
