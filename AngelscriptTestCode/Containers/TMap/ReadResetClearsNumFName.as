/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFName
 */
/**
 * @begin ReadResetClearsNumFName
 * @summary A const&in TMap<FName, int> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
