/**
 * @version v1
 * @summary An &out TSet<FString> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSetFString
 */
/**
 * @begin FillByAppendOtherSetFString
 * @summary An &out TSet<FString> is filled by Append of another set.
 * @topic Containers
 */
void FillByAppendOtherSetFString(TSet<FString>&out Result)
{
	Result.Add("alpha");
	TSet<FString> Other;
	Other.Add("gamma");
	Other.Add("delta");
	Result.Append(Other);
}
/** @end */
