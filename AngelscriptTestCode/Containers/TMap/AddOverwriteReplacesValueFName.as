/**
 * @version v1
 * @summary Add of the same FName key twice keeps Num and stores the last value.
 * @topic Containers
 *
 * AddOverwriteReplacesValueFName
 */
/**
 * @begin AddOverwriteReplacesValueFName
 * @summary Add of the same FName key twice keeps Num and stores the last value.
 * @topic Containers
 */
bool AddOverwriteReplacesValueFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	if (Map.Num() != 1 || Map[n"Red"] != 1)
	{
		return false;
	}

	Map.Add(n"Red", 9);
	return Map.Num() == 1 && Map.Contains(n"Red") && Map[n"Red"] == 9;
}
/** @end */
