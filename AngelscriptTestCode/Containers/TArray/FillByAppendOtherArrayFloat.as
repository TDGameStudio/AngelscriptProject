/**
 * @version v1
 * @summary An &out TArray<float> is filled by Append of another array.
 * @topic Containers
 *
 * FillByAppendOtherArrayFloat
 */
/**
 * @begin FillByAppendOtherArrayFloat
 * @summary An &out TArray<float> is filled by Append of another array.
 * @topic Containers
 */
void FillByAppendOtherArrayFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	TArray<float> Other;
	Other.Add(20.0f);
	Other.Add(30.0f);
	Result.Append(Other);
}
/** @end */
