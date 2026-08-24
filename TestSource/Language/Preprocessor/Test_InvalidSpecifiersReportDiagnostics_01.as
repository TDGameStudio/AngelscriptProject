// Theme: Language.Preprocessor. Isolated compile-fail: global BlueprintEvent.
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
// AssertPreprocessFailed; lines 190-196;
// sha256=7a33edbd1687952b84a769aa92c794e3a6c14812e2fc211fc33f3312fd3d6797.
// Expected diagnostic: "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
// Do not drop BlueprintEvent or wrap this in a UCLASS.
// DiagnosticOnly.

UFUNCTION(BlueprintEvent)
int BadGlobalEvent()
{
	return 1;
}
