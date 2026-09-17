/**
 * @version v1
 * @summary An &inout TArray<int32> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRange
 */
/**
 * @begin MutateCopyRange
 * @summary An &inout TArray<int32> is overwritten in place by Copy.
 * @topic Containers
 */
void MutateCopyRange(TArray<int32>&inout Values)
{
	TArray<int32> Source;
	Source.Add(4);
	Source.Add(5);
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
