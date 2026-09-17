/**
 * @version v1
 * @summary ELogVerbosity is not script-facing, so this program is rejected. C++ compiles it as the module ASCoverageLogging_ELogVerbosityUnsupported and expects the diagnostic to name ELogVerbosity. Do not replace with.
 * @topic Definitions
 */
/**
 * @version root
 * @summary ELogVerbosity is not script-facing, so this program is rejected. C++ compiles it as the module ASCoverageLogging_ELogVerbosityUnsupported and expects the diagnostic to name ELogVerbosity. Do not replace with.
 * @topic Negative
 */
/**
 * The isolated failing program: ELogVerbosity has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Meta.ELogVerbosityUnsupported
 * @Inputs none
 * @Return does not compile; ELogVerbosity enum values are not currently script-facing
 */
int TryNativeVerbosityEnum()
{
	ELogVerbosity Value = ELogVerbosity::VeryVerbose;
	return int(Value);
}
/** @end */
