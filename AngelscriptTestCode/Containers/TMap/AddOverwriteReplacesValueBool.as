/**
 * @version v1
 * @summary Add of the same int key twice keeps Num and stores the last bool.
 * @topic Containers
 *
 * AddOverwriteReplacesValueBool
 */
/**
 * @begin AddOverwriteReplacesValueBool
 * @summary Add of the same int key twice keeps Num and stores the last bool.
 * @topic Containers
 */
bool AddOverwriteReplacesValueBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	if (Map.Num() != 1 || Map[1] != true)
	{
		return false;
	}

	Map.Add(1, false);
	return Map.Num() == 1 && Map.Contains(1) && Map[1] == false;
}
/** @end */
