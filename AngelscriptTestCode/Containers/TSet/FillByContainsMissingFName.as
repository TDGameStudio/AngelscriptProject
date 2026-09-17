/**
 * @version v1
 * @summary An &out TSet<FName> is filled so Contains can miss an absent member.
 * @topic Containers
 *
 * FillByContainsMissingFName
 */
/**
 * @begin FillByContainsMissingFName
 * @summary An &out TSet<FName> is filled so Contains can miss an absent member.
 * @topic Containers
 */
void FillByContainsMissingFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
}
/** @end */
