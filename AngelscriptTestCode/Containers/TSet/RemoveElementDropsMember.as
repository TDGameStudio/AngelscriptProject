/**
 * @version v1
 * @summary Remove of a present member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMember
 */
/**
 * @begin RemoveElementDropsMember
 * @summary Remove of a present member returns true and drops that member.
 * @topic Containers
 */
bool RemoveElementDropsMember()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	bool bRemoved = Values.Remove(1);
	return bRemoved && Values.Num() == 1 && Values.Contains(2) && !Values.Contains(1);
}
/** @end */
