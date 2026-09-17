/**
 * @version v1
 * @summary GetValues copies every stored bool into the destination array.
 * @topic Containers
 *
 * GetValuesListsStoredValuesBool
 */
/**
 * @begin GetValuesListsStoredValuesBool
 * @summary GetValues copies every stored bool into the destination array.
 * @topic Containers
 */
bool GetValuesListsStoredValuesBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Add(2, false);
	TArray<bool> Values;
	Map.GetValues(Values);
	return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
