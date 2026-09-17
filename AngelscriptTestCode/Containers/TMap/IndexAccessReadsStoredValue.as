/**
 * @version v1
 * @summary Bracket access reads and writes an existing int key.
 * @topic Containers
 *
 * IndexAccessReadsStoredValue
 */
/**
 * @begin IndexAccessReadsStoredValue
 * @summary Bracket access reads and writes an existing int key.
 * @topic Containers
 */
bool IndexAccessReadsStoredValue()
{
	TMap<int, int> Map;
	Map.Add(10, 100);
	if (Map[10] != 100)
	{
		return false;
	}

	Map[10] = 999;
	return Map[10] == 999 && Map.Num() == 1;
}
/** @end */
