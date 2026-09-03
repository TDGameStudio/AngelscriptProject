/**
 * A static field on a USTRUCT is not a script-side surface, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.StaticMemberRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.StaticMemberRejected
 * @Kind CompileReject
 * @Covers UStruct.StaticMemberRejected
 * @Inputs static int Value on FStaticMemberBoundary
 * @Return does not compile; USTRUCT static fields stay an unsupported boundary
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT static fields are unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 5
 * @Provenance CompileAndExpectFailure: USTRUCT static fields should remain an unsupported boundary.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

USTRUCT()
struct FStaticMemberBoundary
{
	static int Value;
}
