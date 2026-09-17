/**
 * @version v1
 * @summary An &out TArray<bool> is filled by Append of another array.
 * @topic Containers
 *
 * FillByAppendOtherArrayBool
 */
/**
 * @begin FillByAppendOtherArrayBool
 * @summary An &out TArray<bool> is filled by Append of another array.
 * @topic Containers
 */
void FillByAppendOtherArrayBool(TArray<bool>&out Result)
{
	Result.Add(false);
	TArray<bool> Other;
	Other.Add(true);
	Other.Add(false);
	Result.Append(Other);
}
/** @end */
