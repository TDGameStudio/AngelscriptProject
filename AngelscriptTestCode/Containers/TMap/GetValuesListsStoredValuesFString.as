/**
 * @version v1
 * @summary GetValues copies every stored value from an FString-key map.
 * @topic Containers
 *
 * GetValuesListsStoredValuesFString
 */
/**
 * @begin GetValuesListsStoredValuesFString
 * @summary GetValues copies every stored value from an FString-key map.
 * @topic Containers
 */
bool GetValuesListsStoredValuesFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Add("beta", 200);
	TArray<int> Values;
	Map.GetValues(Values);
	return Values.Num() == 2 && Values.Contains(100) && Values.Contains(200);
}
/** @end */
