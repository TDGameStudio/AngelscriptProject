/**
 * The legacy macro name PLATFORM_WINDOWS is not registered with this fork's
 * preprocessor, so guarding code with it is rejected. This file is the illegal
 * program itself; do not swap in a registered flag, since the unregistered
 * name is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnregisteredPlatformWindowsCondition
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnregisteredPlatformWindowsCondition
 * @Kind CompileReject
 * @Covers Preprocessor.Conditionals
 * @Inputs #if PLATFORM_WINDOWS around a function definition
 * @Return does not preprocess; diagnostic "Invalid preprocessor condition: PLATFORM_WINDOWS"
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::UnregisteredLegacyMacroNamesReportDiagnostics
 * @Provenance AssertPreprocessFailed; lines 261-268;
 * @Provenance sha256=dc106a11a620652b751b6569766cc801cb5a801aaaf6ab70a0b550f80eaf3e26.
 * @Provenance Expected diagnostic: "Invalid preprocessor condition: PLATFORM_WINDOWS" (count 1).
 * @Provenance Do not replace PLATFORM_WINDOWS with a registered flag.
 * @Provenance DiagnosticOnly.
 */

/**
 * The rejected condition: PLATFORM_WINDOWS is not a registered flag, so the
 * condition never opens.
 *
 * @Covers Preprocessor.Conditionals
 * @Inputs the macro name PLATFORM_WINDOWS
 * @Return does not preprocess
 */
#if PLATFORM_WINDOWS
/**
 * The function guarded by the unregistered macro. It never runs, since the
 * condition itself is rejected.
 *
 * @Covers Preprocessor.Conditionals
 * @Inputs none
 * @Return 1, never reached
 */
int Entry()
{
	return 1;
}
#endif
