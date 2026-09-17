/**
 * @version v1
 * @summary Add of the same key twice keeps Num and stores the last value.
 * @topic Containers
 *
 * AddOverwriteReplacesValue
 */
/**
 * @begin AddOverwriteReplacesValue
 * @summary Add of the same key twice keeps Num and stores the last value.
 * @topic Containers
 */
bool AddOverwriteReplacesValue()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	if (Map.Num() != 1 || Map[10] != 100)
	{
		return false;
	}

	Map.Add(10, 999);
	return Map.Num() == 1 && Map.Contains(10) && Map[10] == 999;
}
/** @end */
