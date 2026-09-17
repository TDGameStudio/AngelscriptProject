/**
 * @version v1
 * @summary An &out TArray<float> is filled then Remove deletes every match.
 * @topic Containers
 *
 * FillByRemoveAllMatchesFloat
 */
/**
 * @begin FillByRemoveAllMatchesFloat
 * @summary An &out TArray<float> is filled then Remove deletes every match.
 * @topic Containers
 */
void FillByRemoveAllMatchesFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	Result.Add(3.0f);
	Result.Add(2.0f);
	Result.Add(4.0f);
	Result.Add(2.0f);
	Result.Add(5.0f);
	Result.Remove(2.0f);
}
/** @end */
