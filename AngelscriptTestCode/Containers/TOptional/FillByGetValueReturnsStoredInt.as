/**
 * @version v1
 * @summary An &out TOptional<int32> is filled so GetValue can read it.
 * @topic Containers
 *
 * FillByGetValueReturnsStoredInt
 */
/**
 * @begin FillByGetValueReturnsStoredInt
 * @summary An &out TOptional<int32> is filled so GetValue can read it.
 * @topic Containers
 */
void FillByGetValueReturnsStoredInt(TOptional<int32>&out Result)
{
	Result.Set(7);
}
/** @end */
