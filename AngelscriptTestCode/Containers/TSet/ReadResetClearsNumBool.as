/**
 * @version v1
 * @summary A const&in TSet<bool> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumBool
 */
/**
 * @begin ReadResetClearsNumBool
 * @summary A const&in TSet<bool> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumBool(const TSet<bool>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
