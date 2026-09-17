/**
 * @version v1
 * @summary Fatal is native crash logging rather than a script helper, so this program is rejected. C++ compiles it as the module ASCoverageLogging_FatalFunctionUnsupported and expects the diagnostic to name Fatal. Do not replace.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Fatal is native crash logging rather than a script helper, so this program is rejected. C++ compiles it as the module ASCoverageLogging_FatalFunctionUnsupported and expects the diagnostic to name Fatal. Do not replace.
 * @topic Negative
 */
/**
 * The isolated failing program: Fatal has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Meta.FatalFunctionUnsupported
 * @Inputs none
 * @Return does not compile; Fatal logging is native crash behavior
 */
void TryNativeFatalVerbosity()
{
	Fatal("Coverage fatal");
}
/** @end */
