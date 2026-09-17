/**
 * @version v1
 * @summary An &out TSet<bool> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMemberBool
 */
/**
 * @begin FillByRemoveElementDropsMemberBool
 * @summary An &out TSet<bool> is filled then Remove drops one member.
 * @topic Containers
 */
void FillByRemoveElementDropsMemberBool(TSet<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Remove(true);
}
/** @end */
