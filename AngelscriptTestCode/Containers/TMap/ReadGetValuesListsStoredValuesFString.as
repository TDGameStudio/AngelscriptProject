/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValuesFString
 */
/**
 * @begin ReadGetValuesListsStoredValuesFString
 * @summary A const&in TMap<FString, int> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValuesFString(const TMap<FString, int>&in Values)
{
	TArray<int> OutValues;
	Values.GetValues(OutValues);
	return OutValues.Num() == 3 && OutValues.Contains(100) && OutValues.Contains(200) && OutValues.Contains(300);
}
/** @end */
