// Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(Atomic) is unsupported.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
// lines 3417-3424;
// sha256=9cc7c1ca2fffbd80ff495e4bc45228be34a64b0feb98011a037f42d3230b6e74.
// Expected diagnostic: Unknown class specifier Atomic.
// DiagnosticOnly. Isolated failing program.

USTRUCT(Atomic)
struct FAtomicStruct
{
	UPROPERTY()
	int Value = 1;
}
