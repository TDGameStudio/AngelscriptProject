/**
 * Verbose and VeryVerbose are native log levels rather than script helpers, so
 * this program is rejected. C++ compiles it as the module
 * ASCoverageLogging_VerboseFunctionsUnsupported and expects the diagnostic to
 * name Verbose. Do not replace with Print.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.VerboseFunctionsUnsupported
 * @Harness CompileReject
 * @Tag Definitions.Meta.VerboseFunctionsUnsupported
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: Verbose/VeryVerbose are not AS logging helpers.
 * @Provenance C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 4 CompileAndExpectFailure.
 * @Provenance Expected diagnostic names Verbose.
 * @Provenance Isolate this failing program; do not replace with Print.
 * @Provenance DiagnosticOnly.
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
