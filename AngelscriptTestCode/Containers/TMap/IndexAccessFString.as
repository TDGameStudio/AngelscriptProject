/**
 * @version v1
 * @summary Bracket access reads and writes an existing FString key.
 * @topic Containers
 *
 * IndexAccessFString
 */
/**
 * @begin IndexAccessFString
 * @summary Bracket access reads and writes an existing FString key.
 * @topic Containers
 */
bool IndexAccessFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	if (Map["alpha"] != 100)
	{
		return false;
	}

	Map["alpha"] = 999;
	return Map["alpha"] == 999 && Map.Num() == 1;
}
/** @end */
