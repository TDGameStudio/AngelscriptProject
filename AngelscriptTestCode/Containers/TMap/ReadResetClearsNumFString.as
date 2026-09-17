/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFString
 */
/**
 * @begin ReadResetClearsNumFString
 * @summary A const&in TMap<FString, int> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
