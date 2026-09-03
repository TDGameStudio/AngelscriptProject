/**
 * ELogVerbosity is not script-facing, so this program is rejected. C++ compiles
 * it as the module ASCoverageLogging_ELogVerbosityUnsupported and expects the
 * diagnostic to name ELogVerbosity. Do not replace with Print/Warning helpers.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.ELogVerbosityUnsupported
 * @Harness CompileReject
 * @Tag Definitions.Meta.ELogVerbosityUnsupported
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: ELogVerbosity is not script-facing.
 * @Provenance C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 2 CompileAndExpectFailure.
 * @Provenance Expected diagnostic names ELogVerbosity.
 * @Provenance Isolate this failing program; do not replace with Print/Warning helpers.
 * @Provenance DiagnosticOnly.
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
