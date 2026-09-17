/**
 * @version v1
 * @summary A duplicate bool Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnoredBool
 */
/**
 * @begin AddDuplicateIgnoredBool
 * @summary A duplicate bool Add is ignored and is not appended.
 * @topic Containers
 */
bool AddDuplicateIgnoredBool()
{
	TSet<bool> Values;
	Values.Add(true);
	if (Values.Num() != 1 || !Values.Contains(true))
	{
		return false;
	}

	Values.Add(true);
	return Values.Num() == 1 && Values.Contains(true);
}
/** @end */
