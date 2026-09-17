/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValuesBool
 */
/**
 * @begin ReadGetValuesListsStoredValuesBool
 * @summary A const&in TMap<int, bool> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValuesBool(const TMap<int, bool>&in Values)
{
	TArray<bool> OutValues;
	Values.GetValues(OutValues);
	return OutValues.Num() == 3 && OutValues.Contains(true) && OutValues.Contains(false);
}
/** @end */
