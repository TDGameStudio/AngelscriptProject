/**
 * @version v1
 * @summary Remove of a present FName member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMemberFName
 */
/**
 * @begin RemoveElementDropsMemberFName
 * @summary Remove of a present FName member returns true and drops that member.
 * @topic Containers
 */
bool RemoveElementDropsMemberFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
	bool bRemoved = Values.Remove(n"Red");
	return bRemoved && Values.Num() == 1 && Values.Contains(n"Green") && !Values.Contains(n"Red");
}
/** @end */
