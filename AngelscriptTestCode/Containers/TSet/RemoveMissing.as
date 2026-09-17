/**
 * @version v1
 * @summary Remove of an absent member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissing
 */
/**
 * @begin RemoveMissing
 * @summary Remove of an absent member returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissing()
{
	TSet<int> Values;
	Values.Add(10);
	return !Values.Remove(99) && Values.Num() == 1 && Values.Contains(10);
}
/** @end */
