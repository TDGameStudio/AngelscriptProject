/**
 * @version v1
 * @summary An &out TOptional<FString> is filled so GetValue can read it.
 * @topic Containers
 *
 * FillByGetValueReturnsStoredIntFString
 */
/**
 * @begin FillByGetValueReturnsStoredIntFString
 * @summary An &out TOptional<FString> is filled so GetValue can read it.
 * @topic Containers
 */
void FillByGetValueReturnsStoredIntFString(TOptional<FString>&out Result)
{
	Result.Set("alpha");
}
/** @end */
