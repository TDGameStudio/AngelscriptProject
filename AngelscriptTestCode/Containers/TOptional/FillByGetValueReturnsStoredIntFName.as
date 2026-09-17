/**
 * @version v1
 * @summary An &out TOptional<FName> is filled so GetValue can read it.
 * @topic Containers
 *
 * FillByGetValueReturnsStoredIntFName
 */
/**
 * @begin FillByGetValueReturnsStoredIntFName
 * @summary An &out TOptional<FName> is filled so GetValue can read it.
 * @topic Containers
 */
void FillByGetValueReturnsStoredIntFName(TOptional<FName>&out Result)
{
	Result.Set(n"Red");
}
/** @end */
