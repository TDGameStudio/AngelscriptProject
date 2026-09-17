/**
 * @version v1
 * @summary An &out TArray<float> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 *
 * FillByRemoveSinglePreservesOrderFloat
 */
/**
 * @begin FillByRemoveSinglePreservesOrderFloat
 * @summary An &out TArray<float> is filled then RemoveSingle drops one duplicate.
 * @topic Containers
 */
void FillByRemoveSinglePreservesOrderFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.RemoveSingle(2.0f);
}
/** @end */
