/**
 * @version v1
 * @summary Verbose and VeryVerbose are native log levels rather than script helpers, so this program is rejected. C++ compiles it as the module ASCoverageDebug_VerboseUnsupported and expects the diagnostic to name Verbose.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Verbose and VeryVerbose are native log levels rather than script helpers, so this program is rejected. C++ compiles it as the module ASCoverageDebug_VerboseUnsupported and expects the diagnostic to name Verbose.
 * @topic Negative
 */
/**
 * The isolated failing program: Verbose and VeryVerbose have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.VerboseUnsupported
 * @Inputs none
 * @Return does not compile; Verbose and VeryVerbose are native log levels
 */
void TryVerboseVerbosity()
{
	Verbose("Coverage verbose");
	VeryVerbose("Coverage very verbose");
}
/** @end */
