/**
 * @version v1
 * @summary An &out TArray<int32> is filled then Remove deletes every match.
 * @topic Containers
 *
 * FillByRemoveAllMatches
 */
/**
 * @begin FillByRemoveAllMatches
 * @summary An &out TArray<int32> is filled then Remove deletes every match.
 * @topic Containers
 */
void FillByRemoveAllMatches(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	Result.Add(2);
	Result.Add(4);
	Result.Add(2);
	Result.Add(5);
	Result.Remove(2);
}
/** @end */
