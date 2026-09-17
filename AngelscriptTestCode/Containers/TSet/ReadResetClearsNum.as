/**
 * @version v1
 * @summary A const&in TSet<int32> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNum
 */
/**
 * @begin ReadResetClearsNum
 * @summary A const&in TSet<int32> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNum(const TSet<int32>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
