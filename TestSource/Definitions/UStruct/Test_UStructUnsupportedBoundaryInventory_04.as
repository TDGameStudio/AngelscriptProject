// Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT NetSerialize is unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 4
// CompileAndExpectFailure: USTRUCT NetSerialize should remain an unsupported boundary.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT()
struct FNetSerializeBoundary
{
	bool NetSerialize(FArchive& Ar, UPackageMap* Map, bool& bOutSuccess)
	{
		return false;
	}
}
