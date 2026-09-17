/**
 * @version v1
 * @summary An &out TArray<bool> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRangeBool
 */
/**
 * @begin FillByCopyRangeBool
 * @summary An &out TArray<bool> is filled then overwritten by Copy.
 * @topic Containers
 */
void FillByCopyRangeBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(false);
	Result.Add(false);
	TArray<bool> Source;
	Source.Add(true);
	Source.Add(false);
	Result.Copy(Source, 0, 2, 1);
}
/** @end */
