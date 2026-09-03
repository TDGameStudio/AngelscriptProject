/**
 * Fatal is native crash behaviour rather than a script callable, so this program is
 * rejected. C++ compiles it as the module ASCoverageDebug_FatalUnsupported and
 * expects the diagnostic to name Fatal.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.FatalUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.FatalUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: Fatal is native crash behavior.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
 * @Provenance CompileAndExpectFailure fragment Fatal.
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Fatal.
 */

/**
 * The isolated failing program: Fatal has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.FatalUnsupported
 * @Inputs none
 * @Return does not compile; Fatal is native crash behaviour
 */
void TryFatalVerbosity()
{
	Fatal("Coverage fatal");
}
