/**
 * @version v1
 * @summary An &out TArray<FString> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOneFString
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOneFString
 * @summary An &out TArray<FString> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 */
void FillByFindIndexReturnsFirstOrMinusOneFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("alpha");
}
/** @end */
