/**
 * @version v1
 * @summary Bracket access reads and writes an existing int key in a TMap of bool values.
 * @topic Containers
 *
 * IndexAccessBool
 */
/**
 * @begin IndexAccessBool
 * @summary Bracket access reads and writes an existing int key in a TMap of bool values.
 * @topic Containers
 */
bool IndexAccessBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	if (Map[1] != true)
	{
		return false;
	}

	Map[1] = false;
	return Map[1] == false && Map.Num() == 1;
}
/** @end */
