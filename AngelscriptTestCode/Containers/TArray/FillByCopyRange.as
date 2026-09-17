/**
 * @version v1
 * @summary An &out TArray<int32> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRange
 */
/**
 * @begin FillByCopyRange
 * @summary An &out TArray<int32> is filled then overwritten by Copy.
 * @topic Containers
 */
void FillByCopyRange(TArray<int32>&out Result)
{
	Result.Add(0);
	Result.Add(0);
	Result.Add(0);
	Result.Add(0);
	TArray<int32> Source;
	Source.Add(7);
	Source.Add(8);
	Source.Add(9);
	Result.Copy(Source, 0, 3, 1);
}
/** @end */
