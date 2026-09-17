/**
 * @version v1
 * @summary An &out TArray<int32> is filled by Append of another array.
 * @topic Containers
 *
 * FillByAppendOtherArray
 */
/**
 * @begin FillByAppendOtherArray
 * @summary An &out TArray<int32> is filled by Append of another array.
 * @topic Containers
 */
void FillByAppendOtherArray(TArray<int32>&out Result)
{
	Result.Add(10);
	TArray<int32> Other;
	Other.Add(20);
	Other.Add(30);
	Result.Append(Other);
}
/** @end */
