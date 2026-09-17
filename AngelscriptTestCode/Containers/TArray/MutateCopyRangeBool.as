/**
 * @version v1
 * @summary An &inout TArray<bool> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRangeBool
 */
/**
 * @begin MutateCopyRangeBool
 * @summary An &inout TArray<bool> is overwritten in place by Copy.
 * @topic Containers
 */
void MutateCopyRangeBool(TArray<bool>&inout Values)
{
	TArray<bool> Source;
	Source.Add(true);
	Source.Add(false);
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
