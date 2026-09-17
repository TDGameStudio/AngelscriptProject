/**
 * @version v1
 * @summary A duplicate FName Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnoredFName
 */
/**
 * @begin AddDuplicateIgnoredFName
 * @summary A duplicate FName Add is ignored and is not appended.
 * @topic Containers
 */
bool AddDuplicateIgnoredFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	if (Values.Num() != 1 || !Values.Contains(n"Red"))
	{
		return false;
	}

	Values.Add(n"Red");
	return Values.Num() == 1 && Values.Contains(n"Red");
}
/** @end */
