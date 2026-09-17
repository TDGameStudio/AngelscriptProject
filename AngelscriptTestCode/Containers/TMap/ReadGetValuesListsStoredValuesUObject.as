/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValuesUObject
 */
/**
 * @begin ReadGetValuesListsStoredValuesUObject
 * @summary A const&in TMap<int, UObject> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValuesUObject(const TMap<int, UObject>&in Values)
{
	TArray<UObject> OutValues;
	Values.GetValues(OutValues);
	return OutValues.Num() == 3
		&& OutValues[0] != nullptr
		&& OutValues[1] != nullptr
		&& OutValues[2] != nullptr;
}
/** @end */
