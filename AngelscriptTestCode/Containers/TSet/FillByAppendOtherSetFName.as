/**
 * @version v1
 * @summary An &out TSet<FName> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSetFName
 */
/**
 * @begin FillByAppendOtherSetFName
 * @summary An &out TSet<FName> is filled by Append of another set.
 * @topic Containers
 */
void FillByAppendOtherSetFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	TSet<FName> Other;
	Other.Add(n"Blue");
	Other.Add(n"Yellow");
	Result.Append(Other);
}
/** @end */
