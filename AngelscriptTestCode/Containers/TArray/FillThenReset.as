/**
 * @version v1
 * @summary An &out TArray<int32> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenReset
 */
/**
 * @begin FillThenReset
 * @summary An &out TArray<int32> is filled then emptied by Reset.
 * @topic Containers
 */
void FillThenReset(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	Result.Reset();
}
/** @end */
