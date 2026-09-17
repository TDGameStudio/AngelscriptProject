/**
 * @version v1
 * @summary A duplicate Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnored
 */
/**
 * @begin AddDuplicateIgnored
 * @summary A duplicate Add is ignored and is not appended.
 * @topic Containers
 */
bool AddDuplicateIgnored()
{
	TSet<int> Values;
	Values.Add(10);
	if (Values.Num() != 1 || !Values.Contains(10))
	{
		return false;
	}

	Values.Add(10);
	return Values.Num() == 1 && Values.Contains(10);
}
/** @end */
