/**
 * @version v1
 * @summary An &out TSet<int32> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMember
 */
/**
 * @begin FillByRemoveElementDropsMember
 * @summary An &out TSet<int32> is filled then Remove drops one member.
 * @topic Containers
 */
void FillByRemoveElementDropsMember(TSet<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Remove(1);
}
/** @end */
