/**
 * A USTRUCT Serialize method is not a script-side surface, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SerializeMethodRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.SerializeMethodRejected
 * @Kind CompileReject
 * @Covers UStruct.SerializeMethodRejected
 * @Inputs void Serialize(FArchive&inout Ar) on FSerializeBoundary
 * @Return does not compile; USTRUCT Serialize stays an unsupported boundary
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT Serialize is unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 3
 * @Provenance CompileAndExpectFailure: USTRUCT Serialize should remain an unsupported boundary.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

USTRUCT()
struct FSerializeBoundary
{
	/**
	 * The isolated failing method: USTRUCT Serialize is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.SerializeMethodRejected
	 * @Inputs an archive to serialize into
	 * @Return does not compile; USTRUCT Serialize stays unsupported
	 * @Param Ar the archive
	 */
	void Serialize(FArchive&inout Ar)
	{
	}
}
