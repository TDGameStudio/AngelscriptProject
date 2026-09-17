/**
 * @version v1
 * @summary An &out TArray<int32> is filled then [] writes one slot.
 * @topic Containers
 *
 * FillByIndexAccessReadsAndWrites
 */
/**
 * @begin FillByIndexAccessReadsAndWrites
 * @summary An &out TArray<int32> is filled then [] writes one slot.
 * @topic Containers
 */
void FillByIndexAccessReadsAndWrites(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(30);
	Result[1] = 99;
}
/** @end */
