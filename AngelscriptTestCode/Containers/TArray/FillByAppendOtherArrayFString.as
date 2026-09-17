/**
 * @version v1
 * @summary An &out TArray<FString> is filled by Append of another array.
 * @topic Containers
 *
 * FillByAppendOtherArrayFString
 */
/**
 * @begin FillByAppendOtherArrayFString
 * @summary An &out TArray<FString> is filled by Append of another array.
 * @topic Containers
 */
void FillByAppendOtherArrayFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	TArray<FString> Other;
	Other.Add("beta");
	Other.Add("gamma");
	Result.Append(Other);
}
/** @end */
