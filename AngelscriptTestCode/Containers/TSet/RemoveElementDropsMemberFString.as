/**
 * @version v1
 * @summary Remove of a present FString member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMemberFString
 */
/**
 * @begin RemoveElementDropsMemberFString
 * @summary Remove of a present FString member returns true and drops that member.
 * @topic Containers
 */
bool RemoveElementDropsMemberFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	bool bRemoved = Values.Remove("alpha");
	return bRemoved && Values.Num() == 1 && Values.Contains("beta") && !Values.Contains("alpha");
}
/** @end */
