/**
 * @version v1
 * @summary An &out TArray<bool> is filled then Remove deletes every match.
 * @topic Containers
 *
 * FillByRemoveAllMatchesBool
 */
/**
 * @begin FillByRemoveAllMatchesBool
 * @summary An &out TArray<bool> is filled then Remove deletes every match.
 * @topic Containers
 */
void FillByRemoveAllMatchesBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Remove(true);
}
/** @end */
