/**
 * @version v1
 * @summary An &out TArray<bool> is filled then [] writes one slot.
 * @topic Containers
 *
 * FillByIndexAccessReadsAndWritesBool
 */
/**
 * @begin FillByIndexAccessReadsAndWritesBool
 * @summary An &out TArray<bool> is filled then [] writes one slot.
 * @topic Containers
 */
void FillByIndexAccessReadsAndWritesBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
	Result[1] = false;
}
/** @end */
