/**
 * @version v1
 * @summary A const&in TMap<int, int> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValues
 */
/**
 * @begin ReadGetValuesListsStoredValues
 * @summary A const&in TMap<int, int> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValues(const TMap<int, int>&in Values)
{
	TArray<int> OutValues;
	Values.GetValues(OutValues);
	return OutValues.Num() == 3 && OutValues.Contains(100) && OutValues.Contains(200) && OutValues.Contains(300);
}
/** @end */
