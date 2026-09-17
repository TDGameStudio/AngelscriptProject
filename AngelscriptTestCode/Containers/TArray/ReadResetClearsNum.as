/**
 * @version v1
 * @summary A const&in TArray<int32> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNum
 */
/**
 * @begin ReadResetClearsNum
 * @summary A const&in TArray<int32> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNum(const TArray<int32>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
