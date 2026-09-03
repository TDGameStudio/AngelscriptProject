/**
 * Fatal is native crash logging rather than a script helper, so this program is
 * rejected. C++ compiles it as the module ASCoverageLogging_FatalFunctionUnsupported
 * and expects the diagnostic to name Fatal. Do not replace with PrintError.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.FatalFunctionUnsupported
 * @Harness CompileReject
 * @Tag Definitions.Meta.FatalFunctionUnsupported
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: Fatal() is native crash logging, not an AS helper.
 * @Provenance C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 3 CompileAndExpectFailure.
 * @Provenance Expected diagnostic names Fatal.
 * @Provenance Isolate this failing program; do not replace with PrintError.
 * @Provenance DiagnosticOnly.
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
