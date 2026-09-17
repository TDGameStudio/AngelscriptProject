/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFString
 */
/**
 * @begin ReadEmptyClearsNumFString
 * @summary A const&in TMap<FString, int> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFString(const TMap<FString, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
