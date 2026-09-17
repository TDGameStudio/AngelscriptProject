/**
 * @version v1
 * @summary An &out TArray<bool> is filled with a FindIndex sequence that repeats false.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOneBool
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOneBool
 * @summary An &out TArray<bool> is filled with a FindIndex sequence that repeats false.
 * @topic Containers
 */
void FillByFindIndexReturnsFirstOrMinusOneBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	Result.Add(false);
}
/** @end */
