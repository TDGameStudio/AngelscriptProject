// Theme: Language.Preprocessor. Isolated compile-fail: unregistered PLATFORM_WINDOWS.
// C++: AngelscriptCoveragePreprocessorTests.cpp::UnregisteredLegacyMacroNamesReportDiagnostics
// AssertPreprocessFailed; lines 261-268;
// sha256=dc106a11a620652b751b6569766cc801cb5a801aaaf6ab70a0b550f80eaf3e26.
// Expected diagnostic: "Invalid preprocessor condition: PLATFORM_WINDOWS" (count 1).
// Do not replace PLATFORM_WINDOWS with a registered flag.
// DiagnosticOnly.

#if PLATFORM_WINDOWS
int Entry()
{
	return 1;
}
#endif
