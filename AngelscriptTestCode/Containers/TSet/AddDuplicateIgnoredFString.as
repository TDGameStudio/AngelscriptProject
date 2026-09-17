/**
 * @version v1
 * @summary A duplicate FString Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnoredFString
 */
/**
 * @begin AddDuplicateIgnoredFString
 * @summary A duplicate FString Add is ignored and is not appended.
 * @topic Containers
 */
bool AddDuplicateIgnoredFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	if (Values.Num() != 1 || !Values.Contains("alpha"))
	{
		return false;
	}

	Values.Add("alpha");
	return Values.Num() == 1 && Values.Contains("alpha");
}
/** @end */
