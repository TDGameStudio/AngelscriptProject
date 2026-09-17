/**
 * @version v1
 * @summary An &out TSet<FName> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMemberFName
 */
/**
 * @begin FillByRemoveElementDropsMemberFName
 * @summary An &out TSet<FName> is filled then Remove drops one member.
 * @topic Containers
 */
void FillByRemoveElementDropsMemberFName(TSet<FName>&out Result)
{
	Result.Add(n"Red");
	Result.Add(n"Green");
	Result.Remove(n"Red");
}
/** @end */
