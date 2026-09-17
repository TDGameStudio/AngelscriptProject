/**
 * @version v1
 * @summary Add of the same FString key twice keeps Num and stores the last value.
 * @topic Containers
 *
 * AddOverwriteReplacesValueFString
 */
/**
 * @begin AddOverwriteReplacesValueFString
 * @summary Add of the same FString key twice keeps Num and stores the last value.
 * @topic Containers
 */
bool AddOverwriteReplacesValueFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	if (Map.Num() != 1 || Map["alpha"] != 100)
	{
		return false;
	}

	Map.Add("alpha", 999);
	return Map.Num() == 1 && Map.Contains("alpha") && Map["alpha"] == 999;
}
/** @end */
