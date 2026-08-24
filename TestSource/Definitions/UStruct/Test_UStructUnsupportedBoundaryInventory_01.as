// Theme: Definitions.UStruct. NegativeDiagnostic: property-bag types on USTRUCT.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 1
// CompileAndExpectFailure: FInstancedPropertyBag and FPropertyBag should remain unsupported boundaries.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT()
struct FPropertyBagBoundary
{
	FInstancedPropertyBag Foo;
	FPropertyBag Bar;
}
