/**
 * @version v1
 * @summary An &out TSet<bool> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSetBool
 */
/**
 * @begin FillByAppendOtherSetBool
 * @summary An &out TSet<bool> is filled by Append of another set.
 * @topic Containers
 */
void FillByAppendOtherSetBool(TSet<bool>&out Result)
{
	Result.Add(true);
	TSet<bool> Other;
	Other.Add(false);
	Result.Append(Other);
}
/** @end */
