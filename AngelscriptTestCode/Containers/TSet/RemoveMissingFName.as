/**
 * @version v1
 * @summary Remove of an absent FName member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissingFName
 */
/**
 * @begin RemoveMissingFName
 * @summary Remove of an absent FName member returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissingFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	return !Values.Remove(n"Missing") && Values.Num() == 1 && Values.Contains(n"Red");
}
/** @end */
