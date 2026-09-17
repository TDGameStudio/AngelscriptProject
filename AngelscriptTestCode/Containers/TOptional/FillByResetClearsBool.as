/**
 * @version v1
 * @summary An &out TOptional<bool> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClearsBool
 */
/**
 * @begin FillByResetClearsBool
 * @summary An &out TOptional<bool> is set then Reset back to unset.
 * @topic Containers
 */
void FillByResetClearsBool(TOptional<bool>&out Result)
{
	Result.Set(true);
	Result.Reset();
}
/** @end */
