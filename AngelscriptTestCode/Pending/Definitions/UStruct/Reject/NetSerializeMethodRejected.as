/**
 * @version v1
 * @summary A USTRUCT NetSerialize method is not a script-side surface, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT NetSerialize method is not a script-side surface, so this program is rejected.
 * @topic Negative
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
/** @end */
