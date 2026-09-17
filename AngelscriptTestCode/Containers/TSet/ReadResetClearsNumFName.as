/**
 * @version v1
 * @summary A const&in TSet<FName> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFName
 */
/**
 * @begin ReadResetClearsNumFName
 * @summary A const&in TSet<FName> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFName(const TSet<FName>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
