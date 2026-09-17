/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFName
 */
/**
 * @begin ReadEmptyClearsNumFName
 * @summary A const&in TMap<FName, int> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFName(const TMap<FName, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
