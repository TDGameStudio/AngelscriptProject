/**
 * @version v1
 * @summary Num counts distinct FName keys; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairsFName
 */
/**
 * @begin NumCountsPairsFName
 * @summary Num counts distinct FName keys; overwrite does not grow Num.
 * @topic Containers
 */
bool NumCountsPairsFName()
{
	TMap<FName, int> Map;
	if (Map.Num() != 0)
	{
		return false;
	}

	Map.Add(n"Red", 1);
	if (Map.Num() != 1)
	{
		return false;
	}

	Map.Add(n"Green", 2);
	Map.Add(n"Red", 9);
	return Map.Num() == 2;
}
/** @end */
