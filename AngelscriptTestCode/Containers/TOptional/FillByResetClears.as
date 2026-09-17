/**
 * @version v1
 * @summary An &out TOptional<int32> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClears
 */
/**
 * @begin FillByResetClears
 * @summary An &out TOptional<int32> is set then Reset back to unset.
 * @topic Containers
 */
void FillByResetClears(TOptional<int32>&out Result)
{
	Result.Set(7);
	Result.Reset();
}
/** @end */
