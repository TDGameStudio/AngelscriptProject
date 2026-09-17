/**
 * @version v1
 * @summary GetValues copies every value into the destination array.
 * @topic Containers
 *
 * GetValuesListsStoredValues
 */
/**
 * @begin GetValuesListsStoredValues
 * @summary GetValues copies every value into the destination array.
 * @topic Containers
 */
bool GetValuesListsStoredValues()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	TArray<int32> OutValues;
	OutValues.Add(-7);
	int Before = OutValues.Num();
	Map.GetValues(OutValues);
	int After = OutValues.Num();
	return After == Before + 2
		&& OutValues[After - 1] == -7
		&& OutValues.Contains(1)
		&& OutValues.Contains(2);
}
/** @end */
