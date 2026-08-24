// Theme: Definitions.UFunction. NegativeDiagnostic: global UFUNCTION may not be BlueprintOverride.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case global BlueprintOverride.
// Expected diagnostic: "Global UFUNCTION() BadGlobalOverride may not be BlueprintOverride."
// Isolate this failing program. DiagnosticOnly.

UFUNCTION(BlueprintOverride)
void BadGlobalOverride()
{
}
