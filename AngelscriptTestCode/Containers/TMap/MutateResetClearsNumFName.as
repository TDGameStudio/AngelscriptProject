/**
 * @version v1
 * @summary An &inout TMap<FName, int> is emptied by Reset.
 * @topic Containers
 *
 * MutateResetClearsNumFName
 */
/**
 * @begin MutateResetClearsNumFName
 * @summary An &inout TMap<FName, int> is emptied by Reset.
 * @topic Containers
 */
void MutateResetClearsNumFName(TMap<FName, int>&inout Values)
{
	Values.Reset();
}
/** @end */
