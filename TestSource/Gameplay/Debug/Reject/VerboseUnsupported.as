/**
 * Verbose and VeryVerbose are native log levels rather than script helpers, so this
 * program is rejected. C++ compiles it as the module ASCoverageDebug_VerboseUnsupported
 * and expects the diagnostic to name Verbose.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.VerboseUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.VerboseUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: Verbose/VeryVerbose are not AS helpers.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
 * @Provenance CompileAndExpectFailure fragment Verbose.
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Verbose.
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
