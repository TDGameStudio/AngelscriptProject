/**
 * @version v1
 * @summary An &inout TMap<int, int> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssign
 */
/**
 * @begin MutateCopyAssign
 * @summary An &inout TMap<int, int> is replaced by assigning a new map.
 * @topic Containers
 */
void MutateCopyAssign(TMap<int, int>&inout Values)
{
	TMap<int, int> Source;
	Source.Add(10, 100);
	Source.Add(20, 200);
	Source.Add(30, 300);
	Values = Source;
}
/** @end */
