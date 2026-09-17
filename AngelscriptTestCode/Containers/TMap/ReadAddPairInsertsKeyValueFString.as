/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports Add pairs without writing the map back.
 * @topic Containers
 *
 * ReadAddPairInsertsKeyValueFString
 */
/**
 * @begin ReadAddPairInsertsKeyValueFString
 * @summary A const&in TMap<FString, int> reports Add pairs without writing the map back.
 * @topic Containers
 */
bool ReadAddPairInsertsKeyValueFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma")
		&& Values["alpha"] == 100
		&& Values["beta"] == 200
		&& Values["gamma"] == 300;
}
/** @end */
