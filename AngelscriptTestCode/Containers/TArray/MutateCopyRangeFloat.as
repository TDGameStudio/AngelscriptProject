/**
 * @version v1
 * @summary An &inout TArray<float> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRangeFloat
 */
/**
 * @begin MutateCopyRangeFloat
 * @summary An &inout TArray<float> is overwritten in place by Copy.
 * @topic Containers
 */
void MutateCopyRangeFloat(TArray<float>&inout Values)
{
	TArray<float> Source;
	Source.Add(4.0f);
	Source.Add(5.0f);
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
