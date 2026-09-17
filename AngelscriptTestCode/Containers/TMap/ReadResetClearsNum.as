/**
 * @version v1
 * @summary A const&in TMap<int, int> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNum
 */
/**
 * @begin ReadResetClearsNum
 * @summary A const&in TMap<int, int> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNum(const TMap<int, int>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
