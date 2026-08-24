// Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT static fields are unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 5
// CompileAndExpectFailure: USTRUCT static fields should remain an unsupported boundary.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT()
struct FStaticMemberBoundary
{
	static int Value;
}
