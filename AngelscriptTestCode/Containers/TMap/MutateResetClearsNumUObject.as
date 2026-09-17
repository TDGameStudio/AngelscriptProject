/**
 * @version v1
 * @summary An &inout TMap<int, UObject> is emptied by Reset.
 * @topic Containers
 *
 * MutateResetClearsNumUObject
 */
/**
 * @begin MutateResetClearsNumUObject
 * @summary An &inout TMap<int, UObject> is emptied by Reset.
 * @topic Containers
 */
void MutateResetClearsNumUObject(TMap<int, UObject>&inout Values)
{
	Values.Reset();
}
/** @end */
