/**
 * @version v1
 * @summary Bracket access reads and writes an existing FName key.
 * @topic Containers
 *
 * IndexAccessFName
 */
/**
 * @begin IndexAccessFName
 * @summary Bracket access reads and writes an existing FName key.
 * @topic Containers
 */
bool IndexAccessFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	if (Map[n"Red"] != 1)
	{
		return false;
	}

	Map[n"Red"] = 9;
	return Map[n"Red"] == 9 && Map.Num() == 1;
}
/** @end */
