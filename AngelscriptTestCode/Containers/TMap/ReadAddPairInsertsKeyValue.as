/**
 * @version v1
 * @summary A const&in TMap<int, int> reports Add pairs without writing the map back.
 * @topic Containers
 *
 * ReadAddPairInsertsKeyValue
 */
/**
 * @begin ReadAddPairInsertsKeyValue
 * @summary A const&in TMap<int, int> reports Add pairs without writing the map back.
 * @topic Containers
 */
bool ReadAddPairInsertsKeyValue(const TMap<int, int>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(10) && Values.Contains(20) && Values.Contains(30)
		&& Values[10] == 100
		&& Values[20] == 200
		&& Values[30] == 300;
}
/** @end */
