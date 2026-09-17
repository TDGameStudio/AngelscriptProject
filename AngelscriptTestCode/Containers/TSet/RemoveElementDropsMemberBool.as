/**
 * @version v1
 * @summary Remove of a present bool member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMemberBool
 */
/**
 * @begin RemoveElementDropsMemberBool
 * @summary Remove of a present bool member returns true and drops that member.
 * @topic Containers
 */
bool RemoveElementDropsMemberBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
	bool bRemoved = Values.Remove(true);
	return bRemoved && Values.Num() == 1 && Values.Contains(false) && !Values.Contains(true);
}
/** @end */
