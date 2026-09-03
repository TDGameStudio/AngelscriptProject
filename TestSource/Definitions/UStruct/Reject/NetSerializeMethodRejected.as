/**
 * A USTRUCT NetSerialize method is not a script-side surface, so this program
 * is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.NetSerializeMethodRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.NetSerializeMethodRejected
 * @Kind CompileReject
 * @Covers UStruct.NetSerializeMethodRejected
 * @Inputs bool NetSerialize on FNetSerializeBoundary
 * @Return does not compile; USTRUCT NetSerialize stays an unsupported boundary
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: USTRUCT NetSerialize is unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 4
 * @Provenance CompileAndExpectFailure: USTRUCT NetSerialize should remain an unsupported boundary.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

USTRUCT()
struct FNetSerializeBoundary
{
	/**
	 * The isolated failing method: USTRUCT NetSerialize is not a script API.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.NetSerializeMethodRejected
	 * @Inputs an archive, package map, and success flag
	 * @Return does not compile; USTRUCT NetSerialize stays unsupported
	 * @Param Ar the archive
	 * @Param Map the package map
	 * @Param bOutSuccess written when native NetSerialize would report success
	 */
	bool NetSerialize(FArchive&inout Ar, UPackageMap* Map, bool&out bOutSuccess)
	{
		return false;
	}
}
