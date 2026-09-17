/**
 * @version v1
 * @summary An &out TOptional<FName> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClearsFName
 */
/**
 * @begin FillByResetClearsFName
 * @summary An &out TOptional<FName> is set then Reset back to unset.
 * @topic Containers
 */
void FillByResetClearsFName(TOptional<FName>&out Result)
{
	Result.Set(n"Red");
	Result.Reset();
}
/** @end */
