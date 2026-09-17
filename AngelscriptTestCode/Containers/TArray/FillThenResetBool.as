/**
 * @version v1
 * @summary An &out TArray<bool> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenResetBool
 */
/**
 * @begin FillThenResetBool
 * @summary An &out TArray<bool> is filled then emptied by Reset.
 * @topic Containers
 */
void FillThenResetBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Reset();
}
/** @end */
