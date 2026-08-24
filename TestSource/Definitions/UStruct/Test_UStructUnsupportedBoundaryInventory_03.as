// Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT Serialize is unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 3
// CompileAndExpectFailure: USTRUCT Serialize should remain an unsupported boundary.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT()
struct FSerializeBoundary
{
	void Serialize(FArchive& Ar)
	{
	}
}
