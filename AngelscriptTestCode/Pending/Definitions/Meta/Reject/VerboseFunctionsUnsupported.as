/**
 * @version v1
 * @summary Verbose and VeryVerbose are native log levels rather than script helpers, so this program is rejected. C++ compiles it as the module ASCoverageLogging_VerboseFunctionsUnsupported and expects the diagnostic to name.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Verbose and VeryVerbose are native log levels rather than script helpers, so this program is rejected. C++ compiles it as the module ASCoverageLogging_VerboseFunctionsUnsupported and expects the diagnostic to name.
 * @topic Negative
 */
/**
 * The isolated failing program: Verbose and VeryVerbose have no script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers Meta.VerboseFunctionsUnsupported
 * @Inputs none
 * @Return does not compile; Verbose and VeryVerbose are native log levels
 */
void TryNativeVerboseVerbosity()
{
	Verbose("Coverage verbose");
	VeryVerbose("Coverage very verbose");
}
/** @end */
