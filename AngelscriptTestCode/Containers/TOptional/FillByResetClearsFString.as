/**
 * @version v1
 * @summary An &out TOptional<FString> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClearsFString
 */
/**
 * @begin FillByResetClearsFString
 * @summary An &out TOptional<FString> is set then Reset back to unset.
 * @topic Containers
 */
void FillByResetClearsFString(TOptional<FString>&out Result)
{
	Result.Set("alpha");
	Result.Reset();
}
/** @end */
