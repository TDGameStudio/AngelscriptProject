/**
 * @version v1
 * @summary Num counts distinct int keys in a TMap of bool values; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairsBool
 */
/**
 * @begin NumCountsPairsBool
 * @summary Num counts distinct int keys in a TMap of bool values; overwrite does not grow Num.
 * @topic Containers
 */
bool NumCountsPairsBool()
{
	TMap<int, bool> Map;
	if (Map.Num() != 0)
	{
		return false;
	}

	Map.Add(1, true);
	if (Map.Num() != 1)
	{
		return false;
	}

	Map.Add(2, false);
	Map.Add(1, false);
	return Map.Num() == 2;
}
/** @end */
