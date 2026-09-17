/**
 * @version v1
 * @summary An &inout TMap<int, bool> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssignBool
 */
/**
 * @begin MutateCopyAssignBool
 * @summary An &inout TMap<int, bool> is replaced by assigning a new map.
 * @topic Containers
 */
void MutateCopyAssignBool(TMap<int, bool>&inout Values)
{
	TMap<int, bool> Source;
	Source.Add(1, true);
	Source.Add(2, false);
	Source.Add(3, true);
	Values = Source;
}
/** @end */
