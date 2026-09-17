/**
 * @version v1
 * @summary An &inout TMap<FName, int> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssignFName
 */
/**
 * @begin MutateCopyAssignFName
 * @summary An &inout TMap<FName, int> is replaced by assigning a new map.
 * @topic Containers
 */
void MutateCopyAssignFName(TMap<FName, int>&inout Values)
{
	TMap<FName, int> Source;
	Source.Add(n"Red", 1);
	Source.Add(n"Green", 2);
	Source.Add(n"Blue", 3);
	Values = Source;
}
/** @end */
