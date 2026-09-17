/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumBool
 */
/**
 * @begin ReadResetClearsNumBool
 * @summary A const&in TMap<int, bool> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
