/**
 * @version v1
 * @summary An &out TArray<int32> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOne
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOne
 * @summary An &out TArray<int32> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 */
void FillByFindIndexReturnsFirstOrMinusOne(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(10);
}
/** @end */
