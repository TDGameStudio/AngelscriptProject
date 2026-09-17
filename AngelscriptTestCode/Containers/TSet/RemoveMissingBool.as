/**
 * @version v1
 * @summary Remove of an absent bool member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissingBool
 */
/**
 * @begin RemoveMissingBool
 * @summary Remove of an absent bool member returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissingBool()
{
	TSet<bool> Values;
	Values.Add(true);
	return !Values.Remove(false) && Values.Num() == 1 && Values.Contains(true);
}
/** @end */
