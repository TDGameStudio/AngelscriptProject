// Theme: Definitions.UStruct. NegativeDiagnostic: HasNativeMake / HasNativeBreak specifiers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 2
// CompileAndExpectFailure: "Unknown class specifier HasNativeMake", "Unknown class specifier HasNativeBreak".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT(HasNativeMake = "MakeBoundary", HasNativeBreak = "BreakBoundary")
struct FNativeMakeBreakBoundary
{
	int Value = 0;
}
