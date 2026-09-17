/**
 * @version v1
 * @summary Num counts distinct int keys; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairs
 */
/**
 * @begin NumCountsPairs
 * @summary Num counts distinct int keys; overwrite does not grow Num.
 * @topic Containers
 */
bool NumCountsPairs()
{
	TMap<int, int> Map;
	if (Map.Num() != 0)
	{
		return false;
	}

	Map.Add(10, 100);
	if (Map.Num() != 1)
	{
		return false;
	}

	Map.Add(20, 200);
	Map.Add(10, 999);
	return Map.Num() == 2;
}
/** @end */
