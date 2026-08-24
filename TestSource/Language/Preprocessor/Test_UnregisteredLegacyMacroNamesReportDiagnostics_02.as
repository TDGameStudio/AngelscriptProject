// Theme: Language.Preprocessor. Isolated compile-fail: unregistered WITH_EDITOR.
// C++: AngelscriptCoveragePreprocessorTests.cpp::UnregisteredLegacyMacroNamesReportDiagnostics
// AssertPreprocessFailed; lines 280-287;
// sha256=7b42855cebe53b9f06070fb30b2442c4feca07682204819ae4671e58c3d802e3.
// Expected diagnostic: "Invalid preprocessor condition: WITH_EDITOR" (count 1).
// Do not replace WITH_EDITOR with EDITOR.
// DiagnosticOnly.

#if WITH_EDITOR
int Entry()
{
	return 1;
}
#endif
