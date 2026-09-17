/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValuesFName
 */
/**
 * @begin ReadGetValuesListsStoredValuesFName
 * @summary A const&in TMap<FName, int> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValuesFName(const TMap<FName, int>&in Values)
{
	TArray<int> OutValues;
	Values.GetValues(OutValues);
	return OutValues.Num() == 3 && OutValues.Contains(1) && OutValues.Contains(2) && OutValues.Contains(3);
}
/** @end */
