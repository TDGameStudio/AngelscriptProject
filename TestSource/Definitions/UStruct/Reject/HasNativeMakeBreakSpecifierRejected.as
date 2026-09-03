/**
 * HasNativeMake and HasNativeBreak are not script-side USTRUCT specifiers, so
 * this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.HasNativeMakeBreakSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.HasNativeMakeBreakSpecifierRejected
 * @Kind CompileReject
 * @Covers UStruct.HasNativeMakeBreakSpecifierRejected
 * @Inputs USTRUCT(HasNativeMake = "MakeBoundary", HasNativeBreak = "BreakBoundary")
 * @Return does not compile; diagnostics "Unknown class specifier HasNativeMake" and "Unknown class specifier HasNativeBreak"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: HasNativeMake / HasNativeBreak specifiers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 2
 * @Provenance CompileAndExpectFailure: "Unknown class specifier HasNativeMake", "Unknown class specifier HasNativeBreak".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

USTRUCT(HasNativeMake = "MakeBoundary", HasNativeBreak = "BreakBoundary")
struct FNativeMakeBreakBoundary
{
	int Value = 0;
}
