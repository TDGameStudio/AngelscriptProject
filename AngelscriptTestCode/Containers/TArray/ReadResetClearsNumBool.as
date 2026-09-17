/**
 * @version v1
 * @summary A const&in TArray<bool> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumBool
 */
/**
 * @begin ReadResetClearsNumBool
 * @summary A const&in TArray<bool> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumBool(const TArray<bool>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
