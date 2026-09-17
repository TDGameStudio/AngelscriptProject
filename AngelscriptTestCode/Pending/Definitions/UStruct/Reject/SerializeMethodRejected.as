/**
 * @version v1
 * @summary A USTRUCT Serialize method is not a script-side surface, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT Serialize method is not a script-side surface, so this program is rejected.
 * @topic Negative
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
/** @end */
