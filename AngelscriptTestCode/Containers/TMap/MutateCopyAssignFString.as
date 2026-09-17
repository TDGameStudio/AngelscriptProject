/**
 * @version v1
 * @summary An &inout TMap<FString, int> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssignFString
 */
/**
 * @begin MutateCopyAssignFString
 * @summary An &inout TMap<FString, int> is replaced by assigning a new map.
 * @topic Containers
 */
void MutateCopyAssignFString(TMap<FString, int>&inout Values)
{
	TMap<FString, int> Source;
	Source.Add("alpha", 100);
	Source.Add("beta", 200);
	Source.Add("gamma", 300);
	Values = Source;
}
/** @end */
