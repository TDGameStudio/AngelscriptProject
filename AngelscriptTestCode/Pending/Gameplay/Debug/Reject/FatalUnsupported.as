/**
 * @version v1
 * @summary Fatal is native crash behaviour rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_FatalUnsupported and expects the diagnostic to name Fatal.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Fatal is native crash behaviour rather than a script callable, so this program is rejected. C++ compiles it as the module ASCoverageDebug_FatalUnsupported and expects the diagnostic to name Fatal.
 * @topic Negative
 */
/**
 * The isolated failing program: Fatal has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.FatalUnsupported
 * @Inputs none
 * @Return does not compile; Fatal is native crash behaviour
 */
void TryFatalVerbosity()
{
	Fatal("Coverage fatal");
}
/** @end */
