/**
 * @version v1
 * @summary GetValues copies every stored value from an FName-key map.
 * @topic Containers
 *
 * GetValuesListsStoredValuesFName
 */
/**
 * @begin GetValuesListsStoredValuesFName
 * @summary GetValues copies every stored value from an FName-key map.
 * @topic Containers
 */
bool GetValuesListsStoredValuesFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Add(n"Green", 2);
	TArray<int> Values;
	Map.GetValues(Values);
	return Values.Num() == 2 && Values.Contains(1) && Values.Contains(2);
}
/** @end */
