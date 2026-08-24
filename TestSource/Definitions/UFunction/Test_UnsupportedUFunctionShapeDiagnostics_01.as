// Theme: Definitions.UFunction. NegativeDiagnostic: global UFUNCTION may not be BlueprintEvent.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case global BlueprintEvent.
// Expected diagnostic: "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
// Isolate this failing program. DiagnosticOnly.

UFUNCTION(BlueprintEvent)
int BadGlobalEvent()
{
	return 1;
}
