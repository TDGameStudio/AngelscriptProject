/**
 * @version v1
 * @summary The native ELogVerbosity enum is not script-facing, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ELogVerbosityUnsupported and expects the diagnostic to name ELogVerbosity.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The native ELogVerbosity enum is not script-facing, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ELogVerbosityUnsupported and expects the diagnostic to name ELogVerbosity.
 * @topic Negative
 */
/**
 * The isolated failing program: ELogVerbosity has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.ELogVerbosityUnsupported
 * @Inputs none
 * @Return does not compile; ELogVerbosity is a native enum
 */
int TryNativeVerbosityEnum()
{
	ELogVerbosity Value = ELogVerbosity::VeryVerbose;
	return int(Value);
}
/** @end */
