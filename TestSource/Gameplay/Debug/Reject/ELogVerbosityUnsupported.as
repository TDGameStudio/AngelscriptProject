/**
 * The native ELogVerbosity enum is not script-facing, so this program is rejected.
 * C++ compiles it as the module ASCoverageDebug_ELogVerbosityUnsupported and expects
 * the diagnostic to name ELogVerbosity.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ELogVerbosityUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.ELogVerbosityUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: native ELogVerbosity is not script-facing.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
 * @Provenance CompileAndExpectFailure fragment ELogVerbosity.
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop ELogVerbosity.
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
