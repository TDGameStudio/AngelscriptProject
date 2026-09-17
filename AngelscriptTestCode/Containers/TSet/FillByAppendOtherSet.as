/**
 * @version v1
 * @summary An &out TSet<int32> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSet
 */
/**
 * @begin FillByAppendOtherSet
 * @summary An &out TSet<int32> is filled by Append of another set.
 * @topic Containers
 */
void FillByAppendOtherSet(TSet<int32>&out Result)
{
	Result.Add(1);
	TSet<int32> Other;
	Other.Add(3);
	Other.Add(4);
	Result.Append(Other);
}
/** @end */
