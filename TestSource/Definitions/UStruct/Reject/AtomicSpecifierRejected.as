/**
 * USTRUCT(Atomic) is not a script-side specifier, so this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.AtomicSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.AtomicSpecifierRejected
 * @Kind CompileReject
 * @Covers UStruct.AtomicSpecifierRejected
 * @Inputs USTRUCT(Atomic) on FAtomicStruct
 * @Return does not compile; diagnostic "Unknown class specifier Atomic"
 * @Provenance Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(Atomic) is unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
 * @Provenance lines 3417-3424;
 * @Provenance sha256=9cc7c1ca2fffbd80ff495e4bc45228be34a64b0feb98011a037f42d3230b6e74.
 * @Provenance Expected diagnostic: Unknown class specifier Atomic.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

USTRUCT(Atomic)
struct FAtomicStruct
{
	UPROPERTY()
	int Value = 1;
}
